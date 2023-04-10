open codespace
```
azd login --use-device-code
azd env new {your unique env name}
azd env set OPENAI_API_KEY {your open ai key}
azd up
```

hit /docs endpoint to verify deployed

Run to get .env vars in current shell
```
source <(azd env get-values | awk '{print "export " $0}')
```

run curl command to insert data
```
curl -X POST ${PLUGIN_HOSTNAME}/upsert \
  -H "Authorization: Bearer footoken" \
  -H "Content-type: application/json" \
  -d '{"documents": [ {"text": "The rainbow zebra galloped through a cloud of marshmallow bubbles, singing a symphony of polka-dotted umbrellas.", "metadata": {"source": "file"}}]}'
```

// TODO
run query command to verify data inserted


