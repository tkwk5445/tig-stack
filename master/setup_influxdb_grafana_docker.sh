#!/bin/bash

# Variables
INFLUXDB_VERSION="1.8"
GRAFANA_VERSION="latest"
INFLUXDB_USER="telegraf_user"
INFLUXDB_PASSWORD="telegraf_password"
INFLUXDB_DB="telegraf"

# Update package list and install prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create Docker Compose file
cat <<EOF > docker-compose.yml
version: '3'

services:
  influxdb:
    image: influxdb:${INFLUXDB_VERSION}
    container_name: influxdb
    ports:
      - "8086:8086"
    environment:
      - INFLUXDB_DB=${INFLUXDB_DB}
      - INFLUXDB_ADMIN_USER=${INFLUXDB_USER}
      - INFLUXDB_ADMIN_PASSWORD=${INFLUXDB_PASSWORD}
    volumes:
      - influxdb-data:/var/lib/influxdb

  grafana:
    image: grafana/grafana:${GRAFANA_VERSION}
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin

volumes:
  influxdb-data:
EOF

# Start Docker Compose services
sudo docker-compose up -d

# Output status of Docker containers
sudo docker-compose ps

echo "InfluxDB and Grafana have been set up using Docker Compose."
echo "InfluxDB is running on port 8086."
echo "Grafana is running on port 3000."
echo "InfluxDB 'telegraf' database user: ${INFLUXDB_USER}, password: ${INFLUXDB_PASSWORD}"
echo "Grafana default login user: admin, password: admin"

