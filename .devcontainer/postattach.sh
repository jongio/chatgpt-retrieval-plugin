#!/bin/sh

set -eu

poetry env use python3.10
poetry install --no-root 
export DATASTORE=redis 
export BEARER_TOKEN=footoken 

# Check if the "redis" container is running
if ! docker ps --filter "name=redis" --filter "status=running" --format "{{.Names}}" | grep -q "^redis$"; then
  # If the "redis" container is not running, start it using docker-compose
  docker-compose -f ./examples/docker/redis/docker-compose.yml up -d
else
  echo "The 'redis' container is already running."
fi

# Prompt the user for their OpenAI API key (input will be hidden)
echo "Please enter your OpenAI API key:"
stty -echo  # Turn off terminal echoing
read -r OPENAI_API_KEY
stty echo  # Turn terminal echoing back on
echo  # Add a newline after the hidden input

# Export the OPENAI_API_KEY environment variable
export OPENAI_API_KEY

export PLUGIN_HOSTNAME=https://$CODESPACE_NAME-8000.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN 
./hostconfig.sh


poetry run start