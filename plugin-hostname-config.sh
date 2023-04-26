#!/bin/sh

# Utility function to ensure the URL starts with "https://" and doesn't end with a slash
normalize_url() {
  url="$1"
  # Ensure the URL starts with "https://"
  case "$url" in
    https://*)
      ;;
    *)
      url="https://$url"
      ;;
  esac
  # Trim any trailing slashes
  url="${url%/}"
  printf '%s\n' "$url"
}

# Function to handle the Codespaces environment
handle_codespaces() {
  # Check if CODESPACE_NAME and GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN are set
  if [ -z "$CODESPACE_NAME" ] || [ -z "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN" ]; then
    echo "CODESPACE_NAME and/or GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN environment variables are not set."
    return 1
  fi
  # Set PLUGIN_HOSTNAME to the expanded version of the URL
  PLUGIN_HOSTNAME="https://$CODESPACE_NAME-8000.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
  PLUGIN_HOSTNAME=$(normalize_url "$PLUGIN_HOSTNAME")
}

# Function to handle the App Service environment
handle_app_service() {
  # Check if WEBSITE_HOSTNAME is set
  if [ -z "$WEBSITE_HOSTNAME" ]; then
    echo "WEBSITE_HOSTNAME environment variable is not set."
    return 1
  fi
  PLUGIN_HOSTNAME=$(normalize_url "$WEBSITE_HOSTNAME")
}

# Function to handle the Azure Container App environment
handle_container_app() {
  # Check if CONTAINER_APP_HOSTNAME is set
  if [ -z "$CONTAINER_APP_HOSTNAME" ]; then
    echo "CONTAINER_APP_HOSTNAME environment variable is not set."
    return 1
  fi
  PLUGIN_HOSTNAME=$(normalize_url "$CONTAINER_APP_HOSTNAME")
}

# Main script logic
if [ -n "$PLUGIN_HOSTNAME" ]; then
  # If PLUGIN_HOSTNAME is already set, no further action is needed
  return 0
elif [ "${CODESPACES:-false}" = "true" ]; then
  # If running in Codespaces
  handle_codespaces
elif [ -n "$WEBSITE_HOSTNAME" ]; then
  # If running in App Service
  handle_app_service
elif [ -n "$CONTAINER_APP_HOSTNAME" ]; then
  # If running in Azure Container App
  handle_container_app
else
  echo "PLUGIN_HOSTNAME environment variable is not set."
  return 1
fi

# Export the PLUGIN_HOSTNAME environment variable
export PLUGIN_HOSTNAME

# Output the final value of PLUGIN_HOSTNAME
echo "PLUGIN_HOSTNAME is set to: $PLUGIN_HOSTNAME"
