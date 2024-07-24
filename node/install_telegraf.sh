#!/bin/bash

# Variables
INFLUXDB_URL="http://<master node ip>:8086"
DATABASE="telegraf"
USERNAME="telegraf_user"
PASSWORD="telegraf_password"

# Update package list and install prerequisites
sudo apt-get update

# Install Telegraf
sudo apt-get install -y telegraf

# Configure Telegraf
sudo tee /etc/telegraf/telegraf.conf > /dev/null <<EOF
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  debug = false
  quiet = false
  logfile = "/var/log/telegraf/telegraf.log"
  hostname = ""
  omit_hostname = false

[[outputs.influxdb]]
  urls = ["${INFLUXDB_URL}"]
  database = "${DATABASE}"
  username = "${USERNAME}"
  password = "${PASSWORD}"

[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false

[[inputs.mem]]
[[inputs.disk]]
[[inputs.net]]
[[inputs.processes]]

[[inputs.system]]
  fielddrop = ["uptime_format"]

[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
  container_names = []
  timeout = "5s"
  perdevice = true
  total = false
  docker_label_include = []
  docker_label_exclude = []
  tagexclude = ["cpu"]
EOF

# Enable and start Telegraf service
sudo systemctl enable telegraf
sudo systemctl start telegraf

# Confirm Telegraf is running
sudo systemctl status telegraf

