#!/bin/bash
set -e

source /opt/hermes/.venv/bin/activate
export HERMES_ALLOW_ROOT_GATEWAY=1

OPTIONS_FILE="/data/options.json"
ADDON_CONFIG_ENV="/addon_configs/hermes-agent/.env"

# --- Ensure directories ---
mkdir -p /data/hermes /addon_configs/hermes-agent

export HOME="/data/hermes"
export HERMES_HOME="/data/hermes"

# --- .env is the source of truth ---
# If no .env exists yet, generate one from the HA config UI options
if [ ! -f "$ADDON_CONFIG_ENV" ]; then
    echo "First boot: generating .env from add-on config UI options."
    {
        echo "# Hermes Agent Configuration"
        echo "# Edit this file via HA File Editor at: addon_configs/hermes-agent/.env"
        echo "# Restart the add-on after making changes."
        echo ""
        echo "# Gateway settings"
        echo "GATEWAY_ALLOW_ALL_USERS=true"
        echo "API_SERVER_HOST=0.0.0.0"
        echo "API_SERVER_KEY=$(jq -r '.api_server_key // "hermesagent"' "$OPTIONS_FILE")"
        echo ""
        echo "# Dashboard (port 9119)"
        echo "HERMES_DASHBOARD=1"
        echo "HERMES_DASHBOARD_HOST=0.0.0.0"
        echo "HERMES_DASHBOARD_PORT=9119"
        echo ""
        echo "# Provider API keys"
        if [ -f "$OPTIONS_FILE" ]; then
            KEYS_LENGTH=$(jq -r '.api_keys | length' "$OPTIONS_FILE")
            for ((i=0; i<KEYS_LENGTH; i++)); do
                KEY_NAME=$(jq -r ".api_keys[$i].name" "$OPTIONS_FILE")
                KEY_VALUE=$(jq -r ".api_keys[$i].value" "$OPTIONS_FILE")
                echo "${KEY_NAME}=${KEY_VALUE}"
            done
        fi
    } > "$ADDON_CONFIG_ENV"
fi

# Copy user-editable .env into hermes data dir
echo "Loading .env from addon_configs..."
cp "$ADDON_CONFIG_ENV" /data/hermes/.env

# Source .env into the current shell
set -a
source /data/hermes/.env
set +a

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
