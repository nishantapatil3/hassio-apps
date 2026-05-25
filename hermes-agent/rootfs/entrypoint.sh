#!/bin/bash
set -e

source /opt/hermes/.venv/bin/activate

OPTIONS_FILE="/data/options.json"

# --- Read HA options and export environment ---
if [ -f "$OPTIONS_FILE" ]; then
    echo "Running inside Home Assistant, reading options..."

    # API Server configuration
    API_SERVER_ENABLED=$(jq -r '.api_server_enabled // "true"' "$OPTIONS_FILE")
    API_SERVER_KEY=$(jq -r '.api_server_key // empty' "$OPTIONS_FILE")
    DASHBOARD_ENABLED=$(jq -r '.dashboard_enabled // "true"' "$OPTIONS_FILE")

    export API_SERVER_ENABLED="${API_SERVER_ENABLED}"
    export API_SERVER_HOST="0.0.0.0"

    if [ -n "$API_SERVER_KEY" ]; then
        export API_SERVER_KEY="${API_SERVER_KEY}"
    fi

    if [ "$DASHBOARD_ENABLED" = "true" ]; then
        export HERMES_DASHBOARD=1
        export HERMES_DASHBOARD_HOST="0.0.0.0"
        export HERMES_DASHBOARD_PORT=9119
    fi

    # Export provider API keys
    KEYS_LENGTH=$(jq -r '.api_keys | length' "$OPTIONS_FILE")
    for ((i=0; i<KEYS_LENGTH; i++)); do
        KEY_NAME=$(jq -r ".api_keys[$i].name" "$OPTIONS_FILE")
        KEY_VALUE=$(jq -r ".api_keys[$i].value" "$OPTIONS_FILE")
        if [ -n "$KEY_VALUE" ]; then
            export "${KEY_NAME}=${KEY_VALUE}"
        fi
    done

    echo "Configuration loaded."
else
    echo "No options file found, running with environment defaults."
fi

# --- Ensure data directory ---
mkdir -p /data/hermes

# Point hermes data to persistent storage
export HOME="/data/hermes"
export HERMES_HOME="/data/hermes"

# --- Run setup if first launch ---
if [ ! -f /data/hermes/.initialized ]; then
    echo "First run detected, running setup..."
    hermes setup --non-interactive 2>/dev/null || true
    touch /data/hermes/.initialized
fi

# --- Start Hermes Agent ---
echo "Starting Hermes Agent..."
exec hermes "$@"
