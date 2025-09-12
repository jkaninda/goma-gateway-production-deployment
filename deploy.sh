#!/bin/bash
set -e

DEPLOYMENTS_DIR="$PWD"

if [ $# -eq 0 ]; then
  echo "Available services:"
  for dir in "$DEPLOYMENTS_DIR"/*/; do
    [ -d "$dir" ] || continue
    service=$(basename "$dir")
    echo " - $service"
  done
  echo
  echo "Usage: $0 <service>|all"
  exit 0
fi

service=$1

if [ "$service" = "all" ]; then
  echo "Deploying all services..."
  for dir in "$DEPLOYMENTS_DIR"/*/; do
    [ -d "$dir" ] || continue
    compose_file="$dir/compose.yaml"
    if [ -f "$compose_file" ]; then
      service_name=$(basename "$dir")
      echo "Deploying $service_name stack..."
      (cd "$dir" && docker compose up -d --force-recreate)
      echo "Deploying $service_name stack...done"
    fi
  done
  echo "All services deployed successfully."
  exit 0
fi

service_dir="$DEPLOYMENTS_DIR/$service"
compose_file="$service_dir/compose.yaml"

if [ -f "$compose_file" ]; then
  echo "Deploying $service stack..."
  cd "$service_dir"
  docker compose up -d --force-recreate
  echo "Deploying $service stack...done"
else
  echo "Service '$service' not found. Please select a valid service:"
  for dir in "$DEPLOYMENTS_DIR"/*/; do
    [ -d "$dir" ] || continue
    echo " - $(basename "$dir")"
  done
  exit 1
fi
