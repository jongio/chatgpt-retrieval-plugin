#!/bin/sh
set -e

poetry env use python3.10 && poetry install --no-root

# Check if the "redis" container is running
if ! docker ps --filter "status=running" --format "{{.Names}}" | grep -q "redis"; then
  # If the "redis" container is not running, start it using docker-compose
  echo "Starting 'redis' container..."
  docker-compose -f ./examples/docker/redis/docker-compose.yml up -d
else
  echo "The 'redis' container is already running."
fi

export DATASTORE=redis 
export BEARER_TOKEN=footoken 

. ./plugin-hostname-config.sh

echo "Click on GitHub Codespaces PORTS tab.  Right click on port 8000, and set Port Visibility to Public."
echo "Use the following URL to use this plugin in the OpenAI Plugin store:"
echo $PLUGIN_HOSTNAME
echo "Starting the Plugin API..."
echo "Once it has started, Open a new terminal and run the ./data-seed.sh file"
echo
echo

poetry run start
