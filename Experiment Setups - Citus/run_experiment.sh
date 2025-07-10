#!/bin/bash

set -e

WORKER_COUNT=$1
if [[ -z "$WORKER_COUNT" ]]; then
  echo "Usage: ./run_experiment.sh <NUM_WORKERS>"
  exit 1
fi

TRANSACTIONS_LIST=(5 100 200 300 400 500)

python3 generate_compose.py $WORKER_COUNT

DOCKER_COMPOSE_FILE="docker-compose.generated.yml"
docker compose -f $DOCKER_COMPOSE_FILE up -d --wait

# Step 3: Wait for PostgreSQL to be ready
until docker exec master pg_isready -U postgres; do
  echo "Waiting for master to be ready..."
  sleep 2
done

# --- PATCH START: Force override of max_connections ---
echo "Setting max_connections = 1000 in master and all workers, and restarting citus_manager..."

# Build list of containers
NODES=("master")
for i in $(seq 1 $WORKER_COUNT); do
  NODES+=("worker$i")
done

# Update postgresql.conf and restart each node
for NODE in "${NODES[@]}"; do
  echo "Updating $NODE..."
  docker exec $NODE bash -c "sed -i \"s/^#*max_connections\\s*=.*/max_connections = 1000/\" /var/lib/postgresql/data/postgresql.conf"
  docker restart $NODE
done

# Restart citus_manager (no config change needed)
docker restart citus_manager
# --- PATCH END ---

# Step 4: Copy CSV files into master
for file in customer.csv product.csv orders.csv; do
  docker cp data/$file master:/
done

# Step 5: Initialize pgbench
pgbench -i -p 5432 -h 127.0.0.1 -U postgres -d postgres

# Step 6: Run SQL setup script
cat <<EOF | docker exec -i master psql -U postgres -d postgres
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
);

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
);

SELECT create_distributed_table('customer', 'customer_id');
SELECT create_reference_table('product');
SELECT create_distributed_table('order_trans', 'customer_id');
CREATE SEQUENCE order_id_seq START WITH 200001 INCREMENT BY 1;
\copy customer FROM 'customer.csv' WITH csv;
\copy product FROM 'product.csv' WITH csv;
\copy order_trans FROM 'orders.csv' WITH csv;
EOF

# Step 7: Run pgbench for different -t values and log the output
RESULTS_DIR="results/workers_${WORKER_COUNT}"
mkdir -p "$RESULTS_DIR"

for TCOUNT in "${TRANSACTIONS_LIST[@]}"; do
  echo "Running pgbench with -t $TCOUNT..."
  CMD="pgbench -h 127.0.0.1 -p 5432 -U postgres -d postgres -c 200 -j 8 -t $TCOUNT -M prepared -n -f ../workloads/read50_write50.sql --max-tries=5"

  echo "$CMD" > "$RESULTS_DIR/pgbench_t${TCOUNT}.log"
  $CMD >> "$RESULTS_DIR/pgbench_t${TCOUNT}.log" 2>&1
  wait
  echo "Results saved to $RESULTS_DIR/pgbench_t${TCOUNT}.log"
done

echo "Stopping and removing Yugabyte cluster containers and volumes..."
docker compose -f $DOCKER_COMPOSE_FILE down -v

echo "Experiment complete with $WORKER_COUNT workers."
