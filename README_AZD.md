# Run in Codespaces

1. Open Codespace

   When you open the Codespace, the `.devcontainer/setup.sh` file is run, which will automatically run the Redis container.

1. Codespaces Configuration

   Change Codespace Port 8000 visibility to public, so OpenAI can connect to your Codespaces

   1. Click on GitHub Codespaces PORTS tab.
   1. Right click on port 8000, and set Port Visibility to Public.

1. OpenAI API Key

   Find your OpenAI API key here: https://platform.openai.com/account/api-keys and set that environment variable.

   ```bash
   export OPENAI_API_KEY=yourkeyvalue
   ```

1. Start the Plugin API

   Run the following command to start the Plugin API:

   ```bash
   poetry run start
   ```

1. Data Seeding

   Let's get a sample document loaded into Redis. 
   
   > NOTE: You must do the following after the API has started:

   ```bash
   python ./server/openai_plugin_seed.py
   ```

1. Add Plugin to Chat GPT

   Now you need to register the plugin with OpenAI. You can get the plugin endpoint by running:

   ```bash
   python ./server/openai_plugin_hostname.py
   ```

1. Query via ChatGPT

   Run the following query in ChatGPT: `search docs for rainbow zebra`

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

   Open ChatGPT and add a new plugin using the endpoint that was outputted by `azd up`

1. Query via ChatGPT

   Run the following query in ChatGPT: `search docs for rainbow zebra`

   You should see that that ChatGPT is now using the plugin.
