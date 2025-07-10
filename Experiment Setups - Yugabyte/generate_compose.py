import sys

MASTER = """
services:
  yb-master:
    image: yugabytedb/yugabyte:latest
    container_name: yb-master
    hostname: yb-master
    command: >
      bin/yb-master
        --fs_data_dirs=/home/yugabyte/data
        --master_addresses=yb-master:7100
        --rpc_bind_addresses=yb-master:7100
        --webserver_interface=0.0.0.0
        --webserver_port=7000
        --ysql_enable_auth=false
        --ysql_max_connections=1000
    ports:
      - "7000:7000"
    networks:
      - yb-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:7000 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
"""

TSERVER = """
  yb-tserver{0}:
    image: yugabytedb/yugabyte:latest
    container_name: yb-tserver{0}
    hostname: yb-tserver{0}
    command: >
      bin/yb-tserver
        --fs_data_dirs=/mnt/tserver-data
        --tserver_master_addrs=yb-master:7100
        --rpc_bind_addresses=yb-tserver{0}:9100
        --webserver_interface=0.0.0.0
        --webserver_port=9000
        --pgsql_proxy_bind_address=0.0.0.0:5433
        --ysql_enable_auth=false
        --ysql_max_connections=1000
    ports:
      - "{1}:9000"
    depends_on:
      yb-master:
        condition: service_healthy
    networks:
      - yb-net
"""

FOOTER = """
networks:
  yb-net:
    driver: bridge
"""

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 generate_compose.py <NUM_TSERVERS>")
        return

    n = int(sys.argv[1])
    replication_factor = 3

    compose = MASTER.format(replication_factor=replication_factor)

    for i in range(1, n + 1):
        port = 9000 + i
        expose_pg_port = '      - "5433:5433"\n' if i == 1 else ''
        tserver_block = TSERVER.format(i, port, replication_factor=replication_factor)
        if expose_pg_port:
            tserver_block = tserver_block.replace("ports:\n", f"ports:\n{expose_pg_port}")
        compose += tserver_block

    compose += FOOTER

    with open("docker-compose.generated.yml", "w") as f:
        f.write(compose)

    print(f"Generated docker-compose.generated.yml with {n} TServers.")

if __name__ == "__main__":
    main()
