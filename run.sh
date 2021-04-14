#!/usr/bin/env bash

# This file inspired by this piece of art at
# https://github.com/nickjj/docker-django-example#run

set -euo pipefail

DC="${DC:-exec}"
APP_NAME="${APP_NAME:-influxdb}"

# If we're running in CI we need to disable TTY allocation for docker-compose
# commands that enable it by default, such as exec and run.
TTY=""
if [[ ! -t 1 ]]; then
  TTY="-T"
fi

# -----------------------------------------------------------------------------
# Helper functions start with _ and aren't listed in this script's help menu.
# -----------------------------------------------------------------------------

function _dc {
  docker-compose "${DC}" ${TTY} "${@}"
}

function _build_run_down {
  docker-compose build
  docker-compose run ${TTY} "${@}"
  docker-compose down
}

# -----------------------------------------------------------------------------

function cmd {
  # Run any command you want in the influx container
  _dc influxdb "${@}"
}

function up() {
  echo "Raising docker containers..."
  _dc up -d influxdb
  echo "Setting up influx..."
  influx_setup
  echo "Running Telegraf and Grafana containers..."
  _dc up -d telegraf grafana
}

function influx_setup() {
  . .env
  . ./influxdb/env.influxdb
  # Sets up influxdb.
  wait_on_influx

  cmd influx setup \
    -u "$INFLUX_USERNAME" \
    -p "$INFLUX_PASSWORD" \
    -o "$INFLUX_ORG" \
    -b "$INFLUX_BUCKET" \
    -r "$INFLUX_RETENTION" \
    -f
  # Create admin config
  create_admin_config

  # Create write token
  bucket_id="$(get_influxdb_bucket)"
  telegraf_token="$(create_write_token $bucket_id)"
  token_placeholder="INFLUX_TOKEN=.*"
  sed -i "" "s/INFLUX_TOKEN=.*/INFLUX_TOKEN=$telegraf_token/" "$PWD/telegraf/env.telegraf"

  # Create read token
  grafana_token="$(create_read_token)"
  sed -i "" "s/GRAFANA_READ_TOKEN=.*/GRAFANA_READ_TOKEN=$grafana_token/" "$PWD/grafana/env.grafana"
}

function wait_on_influx() {
  >&2 echo "InfluxDB not ready yet - sleeping"
  sleep 1
  done
}

function create_admin_config() {
  local admin_token="$(cmd influx auth list | grep $INFLUX_USERNAME | awk -F $'\t' '{print $3}')"
  cmd influx config create --config-name administrator --host-url "$INFLUX_HOST" --org "$INFLUX_ORG" --token "$admin_token" --active
}
  echo "$bucket_id"
}

function create_write_token() {
  # use this function with a parameter which is the bucket id
  local token="$(cmd influx auth create --write-bucket "$1" | grep "$INFLUX_USERNAME" | awk '{print $2}')"
  echo "$token"
}

function create_read_token() {
  local token="$(cmd influx auth create \
    --read-buckets \
    --read-checks \
    --read-dashboards \
    --read-dbrps \
    --read-notificationEndpoints \
    --read-notificationRules \
    --read-orgs \
    --read-tasks \
    --read-telegrafs \
    --read-user | grep "$INFLUX_USERNAME" | awk '{print $2}')"
  echo "$token"
}

function wipe_telegraf() {
  local container_name="telegraf"
  docker-compose stop telegraf
  if [ "$(docker ps -q -f name="$container_name")" ]; then
    docker rm "$container_name"
  fi
}

function run_telegraf {
  docker-compose run -d --service-ports telegraf
  docker-compose run -d --service-ports grafana
}

function start_over {
  docker-compose down
  docker volume rm influxdb2-data
  docker volume rm grafana-data
  docker volume rm metrics-caddy-data
  docker volume rm metrics-caddy-config
  docker volume create influxdb2-data
  docker volume create grafana-data
  docker volume create metrics-caddy-data
  docker volume create metrics-caddy-config
}

function help() {
  printf "%s <task> [args]\n\nTasks:\n" "${0}"

  compgen -A function | grep -v "^_" | cat -n

  printf "\nExtended help:\n  Each task has comments for general usage\n"
}

# This idea is heavily inspired by: https://github.com/adriancooney/Taskfile
TIMEFORMAT=$'\nTask completed in %3lR'
time "${@:-help}"
