import os
import subprocess
import json
from urllib.request import Request, urlopen
from urllib.error import HTTPError
from openai_plugin_hostname import get_plugin_hostname  # Import the function

# Check if the first argument is "azd"
if len(os.sys.argv) > 1 and os.sys.argv[1] == "azd":
    # Load environment variables using the azd env get-values command
    output = subprocess.check_output("azd env get-values", shell=True, text=True)
    for line in output.splitlines():
        key, value = line.split("=", 1)
        os.environ[key] = value

print("Adding test data to the Redis cache...\n")

plugin_hostname = get_plugin_hostname()  # Call the function to set plugin_hostname

headers = {
    "Authorization": "Bearer footoken",
    "Content-type": "application/json"
}
data = {
    "documents": [
        {
            "text": "The rainbow zebra galloped through a cloud of marshmallow bubbles, singing a symphony of polka-dotted umbrellas.",
            "metadata": {"source": "file"}
        }
    ]
}

# Convert the data dictionary to a JSON string
data_json = json.dumps(data).encode('utf-8')

# Create a Request object
request = Request(f"{plugin_hostname}/upsert", data=data_json, headers=headers, method='POST')

# Send the request and handle the response
try:
    response = urlopen(request)
    response_text = response.read().decode('utf-8')
    print(response_text)
except HTTPError as e:
    print(f"An HTTP error occurred: {e.code} {e.reason}")

print("\nOpen the following URL to see the OpenAPI Spec")
print(f"{plugin_hostname}/docs")
print("\nUse the following URL to use this plugin in the OpenAI Plugin store")
print(plugin_hostname)
print("\nEnter 'footoken' if OpenAI prompts you for a Bearer Token")
print("\nAfter the Retrieval Plugin is loaded in OpenAI, ask it to 'search docs for rainbow zebra'")
