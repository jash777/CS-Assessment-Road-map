#!/bin/bash

# Function to check if a command succeeded and error out if not
function check_success() {
  if [ $? -ne 0 ]; then
    echo "$1 failed."
    exit 1
  fi
}

# Create necessary directories
mkdir -p promtail-config docker-compose
check_success "Directory creation"



# Create docker-compose.yml
cat << EOF > docker-compose/docker-compose.yml
version: '3.3'  # Or a suitable Docker Compose version
services:
  loki:
    image: grafana/loki:latest
  promtail:
    image: grafana/promtail:latest
    #ports:
    #  - "3100:3100"
    volumes:
      - /var/log:/var/log:ro             # Collect logs from host's /var/log
      - ../promtail-config:/etc/promtail  # Mount Promtail config directory
    command:
      - '-config.file=/etc/promtail/promtail-config.yml'
    depends_on:
      - loki
  node-exporter:
    image: prom/node-exporter:latest
    #ports:
   #  - "9254:9254"
    container_name: node-exporter
    restart: unless-stopped
    volumes:
     - /proc:/host/proc:ro
     - /sys:/host/sys:ro
     - /:/rootfs:ro
    command:
     - '--path.procfs=/host/proc'
     - '--path.sysfs=/host/sys'
     - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($|/)'

EOF
check_success "docker-compose.yml creation"

# Create promtail-config.yml with sample configuration
cat << EOF > promtail-config/promtail-config.yml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log
EOF
check_success "promtail-config.yml creation"

echo "Setup complete! Starting containers..."

# Navigate to the docker-compose directory and start the containers
cd docker-compose
check_success "Changing directory"

docker-compose up -d
check_success "Running docker-compose"

echo "Loki, Promtail, and Node Exporter should now be running."