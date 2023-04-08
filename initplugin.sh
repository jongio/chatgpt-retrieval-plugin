#!/bin/sh
set -eu

echo "Adding test data to the Redis cache..."

# Check if CODESPACES environment variable is set to true
# Provide a default value of "false" if CODESPACES is not set
if [ "${CODESPACES:-false}" = "true" ]; then
  # If CODESPACES is true and PLUGIN_HOSTNAME is undefined or empty, set PLUGIN_HOSTNAME
  if [ -z "$PLUGIN_HOSTNAME" ]; then
    # Check if CODESPACE_NAME and GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN are set
    if [ -z "$CODESPACE_NAME" ] || [ -z "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN" ]; then
      echo "CODESPACE_NAME and/or GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN environment variables are not set."
      exit 1
    fi
    # Set PLUGIN_HOSTNAME to the expanded version of the URL
    PLUGIN_HOSTNAME="https://$CODESPACE_NAME-8000.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
  fi
else
  # If CODESPACES is not true, check if PLUGIN_HOSTNAME is set
  if [ -z "$PLUGIN_HOSTNAME" ]; then
    echo "PLUGIN_HOSTNAME environment variable is not set."
    exit 1
  fi
fi

echo
curl -X POST ${PLUGIN_HOSTNAME}/upsert \
  -H "Authorization: Bearer footoken" \
  -H "Content-type: application/json" \
  -d '{"documents": [ {"text": "The rainbow zebra galloped through a cloud of marshmallow bubbles, singing a symphony of polka-dotted umbrellas.", "metadata": {"source": "file"}}]}'
echo
echo
echo "Open the following URL to see the OpenAPI Spec"
echo "$PLUGIN_HOSTNAME/docs"
echo
echo "Use the following URL to use this plugin in the OpenAI Plugin store"
echo "$PLUGIN_HOSTNAME"
echo
echo "Enter 'footoken' if OpenAI prompts you for a Bearer Token"
echo
echo "After the Retrieval Plugin is loaded in OpenAI, ask it to 'search docs for rainbow zebra'"