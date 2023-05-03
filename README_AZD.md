# Run in Codespaces

1. Open Codespace

   The Codespaces setup configuration will start the redis container locally and set the PLUGIN_HOSTNAME env var needed to integrate with ChatGPT.

1. Add OpenAI API Key environment variable.

   Found here: https://platform.openai.com/account/api-keys

   ```bash
   export OPENAI_API_KEY=yourkeyvalue
   ```

1. Change Port 8000 visibility to public, so OpenAI can connect to the Codespace

   1. Click on GitHub Codespaces PORTS tab.
   2. Right click on port 8000, and set Port Visibility to Public.

1. Seed data

    Run the following to add a document

    ```bash
    ./data-seed.sh
    ```
1. Add Plugin to Chat GPT
   1. Open ChatGPT and add a new plugin using the value of the $PLUGIN_HOSTNAME environment variable. You can get that value by running:

   ```bash
   echo $PLUGIN_HOSTNAME
   ```

1. Query via ChatGPT   
    1. Run the following query in ChatGPT: `search docs for rainbow zebra`

        You should see that that ChatGPT is now using the plugin.

# Run on Azure

1. Setup Azure Developer CLI environment

    ```bash
    azd auth login --use-device-code
    azd env new {your unique env name}
    azd env set OPENAI_API_KEY {your open ai key}
    ```

1. Provision resources and deploy code

    ```bash
    azd up
    ```

    When it is finished it will output an API endpoint. Hit the `/docs` endpoint to verify that it is working.

1. Seed data

    Run the following to add a document using the azd environment values

    ```bash
    python ./server/openai_plugin_seed.py azd
    ```

1. Add Plugin to Chat GPT
   1. Open ChatGPT and add a new plugin using the endpoint that was outputted by `azd up`  

1. Query via ChatGPT
    1. Run the following query in ChatGPT: `search docs for rainbow zebra`

        You should see that that ChatGPT is now using the plugin.
