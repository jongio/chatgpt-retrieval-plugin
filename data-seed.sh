#!/bin/sh
set -e

# Check if the first argument is "azure"
if [ "$1" = "azd" ]; then
  # Load environment variables using the azd env get-values command
  source <(azd env get-values | awk '{print "export " $0}')
fi

echo "Adding test data to the Redis cache..."

. ./plugin-hostname-config.sh

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