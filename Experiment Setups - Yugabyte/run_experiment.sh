#!/bin/bash

set -e

T_SERVER_COUNT=$1
if [[ -z "$T_SERVER_COUNT" ]]; then
  echo "Usage: ./run_yb_experiment.sh <NUM_TSERVERS>"
  echo "Example: ./run_yb_experiment.sh 2"
  exit 1
fi

TRANSACTIONS_LIST=(5 100 200 300 400 500)

RESULTS_DIR="results/yugabyte_tservers_${T_SERVER_COUNT}"
mkdir -p "$RESULTS_DIR"

# Step 1: Generate docker-compose.yml from template
python3 generate_compose.py $T_SERVER_COUNT
DOCKER_COMPOSE_FILE="docker-compose.generated.yml"

# Step 2: Launch Yugabyte cluster
echo "Starting Yugabyte cluster with $T_SERVER_COUNT tablet servers..."
docker compose -f $DOCKER_COMPOSE_FILE up -d --wait

# Step 3: Wait for yb-tserver1 to respond to SQL
for i in {1..30}; do
  if docker exec yb-tserver1 ysqlsh -h 127.0.0.1 -p 5433 -U yugabyte -c "SELECT 1;" > /dev/null 2>&1; then
    echo "yb-tserver1 is ready."
    break
  fi
  echo "Waiting for yb-tserver1 to be ready... ($i/30)"
  sleep 2
  if [[ $i -eq 30 ]]; then
    echo "yb-tserver1 did not become ready in time."
    exit 1
  fi
done

# Step 4: Copy CSV files to yb-tserver1
for file in customer.csv product.csv orders.csv; do
  docker cp data/$file yb-tserver1:/home/yugabyte/
done

# Step 5: Setup database, tables, and import CSVs
echo "Creating tables and loading data..."
cat <<EOF | docker exec -i yb-tserver1 bash -c "ysqlsh -h 127.0.0.1 -p 5433 -U yugabyte"
CREATE DATABASE demo with COLOCATION = true;
\c demo;

CREATE TABLE customer (
    customer_id INT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(100),
    address VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    customer_state VARCHAR(100) NOT NULL,
    zip_code VARCHAR(100) NOT NULL,
    registration_date DATE NOT NULL,
    PRIMARY KEY (customer_id)
) WITH (COLOCATION = false);

CREATE TABLE product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    product_cost DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL,
    supplier VARCHAR(100) NOT NULL,
    created_date DATE NOT NULL
);

CREATE TABLE order_trans (
    order_id BIGINT NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(100) NOT NULL,
    shipping_address TEXT NOT NULL,
    status VARCHAR(100) NOT NULL,
    PRIMARY KEY (order_id, customer_id, product_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
) WITH (COLOCATION = false);

\copy customer FROM 'customer.csv' WITH csv;
\copy product FROM 'product.csv' WITH csv;
\copy order_trans FROM 'orders.csv' WITH csv;

CREATE SEQUENCE order_id_seq START WITH 200001 INCREMENT BY 1;
EOF

# Step 6: Initialize pgbench
pgbench -i -p 5433 -h 127.0.0.1 -U yugabyte demo
# Step 7: Run pgbench for each transaction count
for TCOUNT in "${TRANSACTIONS_LIST[@]}"; do
  echo "Running pgbench with -t $TCOUNT..."
  # CMD="pgbench -h 127.0.0.1 -p 5433 -U yugabyte -d demo -c 50 -j 4 -t $TCOUNT -M prepared"
  CMD="pgbench -h 127.0.0.1 -p 5433 -U yugabyte -d demo -c 200 -j 8 -t $TCOUNT -M prepared -n -f ../workloads/read50_write50.sql --max-tries=5"
  echo "$CMD" > "$RESULTS_DIR/pgbench_t${TCOUNT}.log"
  $CMD >> "$RESULTS_DIR/pgbench_t${TCOUNT}.log" 2>&1
  wait
  echo "Results saved to $RESULTS_DIR/pgbench_t${TCOUNT}.log"
  
done


# Step 7: Tear down cluster and remove volumes
echo "Stopping and removing Yugabyte cluster containers and volumes..."
docker compose -f $DOCKER_COMPOSE_FILE down -v 

# Step 8: Done
echo "✅ YugabyteDB experiment complete with $T_SERVER_COUNT tablet servers."
echo "View results under: $RESULTS_DIR"
