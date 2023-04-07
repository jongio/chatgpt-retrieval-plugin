#!/bin/sh

# Check if PLUGIN_HOSTNAME is set
if [ -z "$PLUGIN_HOSTNAME" ]; then
  echo "PLUGIN_HOSTNAME environment variable is not set."
  exit 1
fi

# Input JSON file
json_input_file="./.well-known/ai-plugin.json"

# Input YAML file
yaml_input_file="./.well-known/openapi.yaml"

# Create temporary files to store the modified JSON and YAML
temp_json_file=$(mktemp)
temp_yaml_file=$(mktemp)

# Read the JSON file and perform the substitutions using jq
jq --arg plugin_hostname "$PLUGIN_HOSTNAME" '
  .api.url = ($plugin_hostname + "/.well-known/openapi.yaml") |
  .logo_url = ($plugin_hostname + "/.well-known/logo.png")
' "$json_input_file" > "$temp_json_file"

# Read the YAML file and perform the substitutions using yq
yq eval --inplace ".info.servers[0].url = \"$PLUGIN_HOSTNAME\"" "$yaml_input_file"

# Overwrite the original JSON file with the modified contents
mv "$temp_json_file" "$json_input_file"

# Print success messages
echo "JSON file has been updated successfully."
echo "YAML file has been updated successfully."
