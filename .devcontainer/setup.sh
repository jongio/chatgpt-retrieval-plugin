#!/bin/sh
set -e

poetry env use python3.10 && poetry install --no-root

echo "====================="
echo "STARTING LOCAL REDIS CONTAINER"
echo "====================="

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

# Function to print a section header with a given title
print_header() {
  echo
  echo "====================="
  echo "$1"
  echo "====================="
  echo
}

print_header "CODESPACES CONFIGURATION"
echo "1. Click on GitHub Codespaces PORTS tab."
echo "2. Right click on port 8000, and set Port Visibility to Public."
echo

print_header "OPENAI API KEY"
echo "1. Go here: https://platform.openai.com/account/api-keys"
echo "2. Copy your OpenAI API key"
echo "3. Run the following to set that key in your environment"
echo "   export OPENAI_API_KEY=yourkeyvalue"
echo

print_header "START PLUGIN API"
echo "Run the following command to start the Plugin API"
echo "'poetry run start'"

print_header "DATA SEEDING"
echo "Let's get a sample document loaded into Redis. You must do the following after the API has started:"
echo "1. Open a new Terminal"
echo "2. Run 'python ./server/openai_plugin_seed.py' to seed the plugin with data."
echo

print_header "OPENAI PLUGIN"
echo "Now you need to register the plugin with OpenAI."
echo "You can get the plugin endpoint by running: 'python ./server/openai_plugin_hostname.py'"
