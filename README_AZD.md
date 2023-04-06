open codespace
azd login --use-device-code
azd env new {your unique env name}
azd env set BEARER_TOKEN footoken
azd env set OPENAI_API_KEY {your open ai key}
azd up

hit /docs endpoint to verify deployed

source .env file from ./.azure/{env}/.env, i.e. `source ./.azure/jong-ret-003/.env`

run curl command to insert data

curl -X POST ${SERVICE_API_URI}/upsert   -H "Authorization: Bearer footoken"   -H "Content-type: application/json"   -d '{"documents": [{"id": "doc1", "text": "Hello world", "metadata": {"source_id": "12345", "source": "file"}}, {"text": "How are you?", "metadata": {"source_id": "23456"}}]}'

// TODO
run query command to verify data inserted
