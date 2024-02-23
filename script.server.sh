#!/bin/bash

function check_success() {
  if [ $? -ne 0 ]; then
    echo "$1 failed."
    exit 1
  fi
}

# Prompt for Prometheus targets (comma-separated list)
#read -p "Enter comma-separated Prometheus targets (e.g., node-exporter:9100,myapp:8080/metrics): " PROMETHEUS_TARGETS

# Create necessary directories
mkdir -p prometheus-config docker-compose
check_success "Directory creation"

# Create docker-compose.yml
cat << EOF > docker-compose/docker-compose.yml
version: '3.3'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ../prometheus-config:/etc/prometheus
   #ports:
   #  - 9090:9090
EOF
check_success "docker-compose.yml creation"

# Create Prometheus configuration (prometheus.yml)
cat << EOF > prometheus-config/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'user_targets'
    static_configs:
      - targets: ['node-exporter.alphasec.org']   #Target  IP address or hostname of the node exporter you want to monitor
EOF
check_success "prometheus.yml creation"

# Start the containers
cd docker-compose
check_success "Changing directory"
docker-compose up -d
check_success "Running docker-compose"

echo "Setup complete! You can access:"
echo "* Prometheus at http://localhost:9090"