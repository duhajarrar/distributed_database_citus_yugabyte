import sys
from pathlib import Path

template = """\
version: '3.8'

services:
  master:
    container_name: "master"
    image: "citusdata/citus:latest"
    ports:
      - "5432:5432"
    labels: ["com.citusdata.role=Master"]
    environment: &AUTH
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "postgres"
      PGUSER: "postgres"
      PGPASSWORD: "postgres"
      POSTGRES_HOST_AUTH_METHOD: "trust"
    networks:
      - citus-net
    command: >
      -c shared_preload_libraries='citus,pg_stat_statements'
      -c pg_stat_statements.track=all
      -c track_activity_query_size=2048
      -c max_connections=1000
      -c shared_buffers=256MB

  manager:
    container_name: "citus_manager"
    image: "citusdata/membership-manager:0.3.0"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - healthcheck-volume:/healthcheck
    depends_on:
      - master
    environment: *AUTH
    networks:
      - citus-net
"""

worker_template = """
  worker{0}:
    container_name: "worker{0}"
    image: "citusdata/citus:latest"
    labels: ["com.citusdata.role=Worker"]
    depends_on:
      - manager
    environment: *AUTH
    volumes:
      - healthcheck-volume:/healthcheck
    networks:
      - citus-net
    command: >
      bash -c "
      /wait-for-manager.sh &&
      /docker-entrypoint.sh postgres
      -c shared_preload_libraries='pg_stat_statements'
      -c pg_stat_statements.track=all
      -c track_activity_query_size=2048
      -c max_connections=1000
      -c shared_buffers=256MB
      "
"""

footer = """
networks:
  citus-net:
    driver: bridge

volumes:
  healthcheck-volume:
"""

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 generate_compose.py <NUM_WORKERS>")
        sys.exit(1)

    num_workers = int(sys.argv[1])
    compose = template
    for i in range(1, num_workers + 1):
        compose += worker_template.format(i)
    compose += footer

    with open("docker-compose.generated.yml", "w") as f:
        f.write(compose)

    print(f"Generated docker-compose.generated.yml with {num_workers} workers.")

if __name__ == "__main__":
    main()
