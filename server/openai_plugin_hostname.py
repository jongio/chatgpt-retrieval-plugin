# plugin_hostname.py
import os

def normalize_url(url):
    # Remove any single quotes and double quotes from the URL
    url = url.replace("'", "").replace('"', '')
    if not url.startswith("https://"):
        url = "https://" + url
    return url.rstrip("/")

def get_plugin_hostname():
    if (plugin_hostname := os.environ.get("PLUGIN_HOSTNAME")):
        plugin_hostname = normalize_url(plugin_hostname)
    elif (codespaces := os.environ.get("CODESPACES", "false")) == "true":
        codespace_name = os.environ.get("CODESPACE_NAME")
        port_forwarding_domain = os.environ.get("GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN")
        if not codespace_name or not port_forwarding_domain:
            raise ValueError("CODESPACE_NAME and/or GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN environment variables are not set.")
        plugin_hostname = normalize_url(f"https://{codespace_name}-8000.{port_forwarding_domain}")
    elif (website_hostname := os.environ.get("WEBSITE_HOSTNAME")):
        plugin_hostname = normalize_url(website_hostname)
    elif (container_app_hostname := os.environ.get("CONTAINER_APP_HOSTNAME")):
        plugin_hostname = normalize_url(container_app_hostname)
    else:
        raise ValueError("PLUGIN_HOSTNAME environment variable is not set.")
    
    # Set the PLUGIN_HOSTNAME environment variable
    os.environ["PLUGIN_HOSTNAME"] = plugin_hostname

    print()
    print("=====================")
    print("PLUGIN API HOSTNAME:")
    print("=====================")
    print(f"Use this hostname when registering this plugin with OpenAI: {plugin_hostname}")
    print()

    return plugin_hostname

# Check if the script is being run as the main module
if __name__ == "__main__":
    # If so, call the get_plugin_hostname() function
    get_plugin_hostname()
