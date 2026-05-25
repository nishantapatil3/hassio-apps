#!/bin/bash
set -e

source /opt/hermes/.venv/bin/activate
export HERMES_ALLOW_ROOT_GATEWAY=1

OPTIONS_FILE="/data/options.json"

# --- Read HA options and export environment ---
if [ -f "$OPTIONS_FILE" ]; then
    echo "Running inside Home Assistant, reading options..."

    # API Server configuration
    API_SERVER_ENABLED=$(jq -r '.api_server_enabled // "true"' "$OPTIONS_FILE")
    API_SERVER_KEY=$(jq -r '.api_server_key // empty' "$OPTIONS_FILE")
    GATEWAY_ALLOW_ALL_USERS=$(jq -r '.gateway_allow_all_users // "true"' "$OPTIONS_FILE")
    DASHBOARD_ENABLED=$(jq -r '.dashboard_enabled // "true"' "$OPTIONS_FILE")

    export API_SERVER_ENABLED="${API_SERVER_ENABLED}"
    export API_SERVER_HOST="0.0.0.0"
    export API_SERVER_KEY="${API_SERVER_KEY:-hermesagent}"
    export GATEWAY_ALLOW_ALL_USERS="${GATEWAY_ALLOW_ALL_USERS}"

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

# --- .env: user-editable file takes priority, otherwise generate from config UI ---
ADDON_CONFIG_ENV="/addon_configs/hermes-agent/.env"
if [ -f "$ADDON_CONFIG_ENV" ]; then
    echo "Using .env from addon_configs (editable via File Editor)."
    cp "$ADDON_CONFIG_ENV" /data/hermes/.env
else
    echo "No custom .env found, generating from add-on config UI options."
    {
        echo "# Edit this file via HA File Editor at /addon_configs/hermes-agent/.env"
        echo "# Changes here override the add-on config UI settings."
        echo ""
        echo "GATEWAY_ALLOW_ALL_USERS=${GATEWAY_ALLOW_ALL_USERS:-true}"
        echo "API_SERVER_KEY=${API_SERVER_KEY:-hermesagent}"
        echo "API_SERVER_HOST=0.0.0.0"
        if [ -f "$OPTIONS_FILE" ]; then
            KEYS_LENGTH=$(jq -r '.api_keys | length' "$OPTIONS_FILE")
            for ((i=0; i<KEYS_LENGTH; i++)); do
                KEY_NAME=$(jq -r ".api_keys[$i].name" "$OPTIONS_FILE")
                KEY_VALUE=$(jq -r ".api_keys[$i].value" "$OPTIONS_FILE")
                if [ -n "$KEY_VALUE" ]; then
                    echo "${KEY_NAME}=${KEY_VALUE}"
                fi
            done
        fi
    } > /data/hermes/.env
    # Copy generated .env to addon_configs so user can edit it next time
    mkdir -p /addon_configs/hermes-agent
    cp /data/hermes/.env "$ADDON_CONFIG_ENV"
fi

# --- Run setup if first launch ---
if [ ! -f /data/hermes/.initialized ]; then
    echo "First run detected, running setup..."
    hermes setup --non-interactive 2>/dev/null || true
    touch /data/hermes/.initialized
fi

# --- Start dashboard in background if enabled ---
if [ "${HERMES_DASHBOARD}" = "1" ]; then
    echo "Starting hermes dashboard on ${HERMES_DASHBOARD_HOST:-0.0.0.0}:${HERMES_DASHBOARD_PORT:-9119} (background)"
    hermes dashboard \
        --host "${HERMES_DASHBOARD_HOST:-0.0.0.0}" \
        --port "${HERMES_DASHBOARD_PORT:-9119}" \
        --no-open --insecure 2>&1 | sed -u 's/^/[dashboard] /' &
fi

# --- Start Hermes Agent ---
echo "Starting Hermes Agent..."
exec hermes "$@"
