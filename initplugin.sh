#!/bin/sh
set -eu

echo "Adding test data to the Redis cache..."
export PLUGIN_HOSTNAME=https://$CODESPACE_NAME-8000.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN 
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