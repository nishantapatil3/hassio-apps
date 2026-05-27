#!/bin/bash
set -e

source /opt/hermes/.venv/bin/activate
export HERMES_ALLOW_ROOT_GATEWAY=1

OPTIONS_FILE="/data/options.json"

# --- Ensure directories ---
mkdir -p /data/hermes

export HOME="/data/hermes"
export HERMES_HOME="/data/hermes"

# --- Generate .env from HA config UI options ---
echo "Generating .env from add-on configuration..."
{
    echo "# Auto-generated from Home Assistant add-on configuration"
    echo "# Change settings via: Settings > Add-ons > Hermes Agent > Configuration"
    echo ""
    echo "# Gateway settings"
    echo "GATEWAY_ALLOW_ALL_USERS=$(jq -r '.gateway_allow_all_users // true' "$OPTIONS_FILE")"
    echo "API_SERVER_HOST=0.0.0.0"
    echo "API_SERVER_KEY=$(jq -r '.api_server_key // "hermesagent"' "$OPTIONS_FILE")"
    echo ""
    echo "# Dashboard"
    DASHBOARD_ENABLED=$(jq -r '.dashboard_enabled // true' "$OPTIONS_FILE")
    if [ "$DASHBOARD_ENABLED" = "true" ]; then
        echo "HERMES_DASHBOARD=1"
    else
        echo "HERMES_DASHBOARD=0"
    fi
    echo "HERMES_DASHBOARD_HOST=0.0.0.0"
    echo "HERMES_DASHBOARD_PORT=$(jq -r '.dashboard_port // 9119' "$OPTIONS_FILE")"
    echo ""
    echo "# Language & Timeouts"
    LANG_VAL=$(jq -r '.hermes_language // "en"' "$OPTIONS_FILE")
    [ -n "$LANG_VAL" ] && echo "HERMES_LANGUAGE=${LANG_VAL}"
    TIMEOUT_VAL=$(jq -r '.hermes_api_timeout // 1800' "$OPTIONS_FILE")
    echo "HERMES_API_TIMEOUT=${TIMEOUT_VAL}"
    YOLO_VAL=$(jq -r '.hermes_yolo_mode // false' "$OPTIONS_FILE")
    if [ "$YOLO_VAL" = "true" ]; then
        echo "HERMES_YOLO_MODE=1"
    fi
    echo ""
    echo "# Provider API keys"
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
    echo ""
    echo "# Search & tool API keys"
    TAVILY=$(jq -r '.tavily_api_key // ""' "$OPTIONS_FILE")
    [ -n "$TAVILY" ] && echo "TAVILY_API_KEY=${TAVILY}"
    FIRECRAWL=$(jq -r '.firecrawl_api_key // ""' "$OPTIONS_FILE")
    [ -n "$FIRECRAWL" ] && echo "FIRECRAWL_API_KEY=${FIRECRAWL}"
    EXA=$(jq -r '.exa_api_key // ""' "$OPTIONS_FILE")
    [ -n "$EXA" ] && echo "EXA_API_KEY=${EXA}"
    SEARXNG=$(jq -r '.searxng_url // ""' "$OPTIONS_FILE")
    [ -n "$SEARXNG" ] && echo "SEARXNG_URL=${SEARXNG}"
} > /data/hermes/.env

# --- Generate config.yaml from HA config UI options ---
echo "Generating config.yaml from add-on configuration..."
{
    echo "# Auto-generated from Home Assistant add-on configuration"
    echo ""
    echo "model:"
    echo "  default: $(jq -r '.model_default // "anthropic/claude-sonnet-4-20250514"' "$OPTIONS_FILE")"
    echo "  provider: $(jq -r '.model_provider // "anthropic"' "$OPTIONS_FILE")"
    echo ""
    echo "terminal:"
    echo "  backend: $(jq -r '.terminal_backend // "local"' "$OPTIONS_FILE")"
    echo ""
    echo "memory:"
    MEMORY_ENABLED=$(jq -r '.memory_enabled // true' "$OPTIONS_FILE")
    echo "  memory_enabled: ${MEMORY_ENABLED}"
    echo ""
    echo "compression:"
    COMP_ENABLED=$(jq -r '.compression_enabled // true' "$OPTIONS_FILE")
    echo "  enabled: ${COMP_ENABLED}"
    COMP_THRESH=$(jq -r '.compression_threshold // 0.50' "$OPTIONS_FILE")
    echo "  threshold: ${COMP_THRESH}"
    echo ""
    echo "agent:"
    echo "  max_turns: $(jq -r '.agent_max_turns // 90' "$OPTIONS_FILE")"
    REASONING=$(jq -r '.agent_reasoning_effort // ""' "$OPTIONS_FILE")
    if [ -n "$REASONING" ]; then
        echo "  reasoning_effort: \"${REASONING}\""
    fi
    echo ""
    WEB_BACKEND=$(jq -r '.web_search_backend // ""' "$OPTIONS_FILE")
    if [ -n "$WEB_BACKEND" ]; then
        echo "web:"
        echo "  backend: ${WEB_BACKEND}"
        echo "  search_backend: ${WEB_BACKEND}"
    fi
} > /data/hermes/config.yaml

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
