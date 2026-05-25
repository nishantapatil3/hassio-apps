#!/bin/bash
set -e

OPTIONS_FILE="/data/options.json"
OPENCLAW_DATA="/data/openclaw"
OPENCLAW_CONFIG="${OPENCLAW_DATA}/openclaw.json"

# --- Ensure data directory ---
mkdir -p "${OPENCLAW_DATA}/workspace"

# --- Read HA options and configure ---
if [ -f "$OPTIONS_FILE" ]; then
    echo "Running inside Home Assistant, reading options..."

    GATEWAY_TOKEN=$(jq -r '.gateway_token // empty' "$OPTIONS_FILE")
    GATEWAY_BIND=$(jq -r '.gateway_bind // "lan"' "$OPTIONS_FILE")
    LITELLM_BASE_URL=$(jq -r '.litellm_base_url // empty' "$OPTIONS_FILE")
    LITELLM_API_KEY=$(jq -r '.litellm_api_key // empty' "$OPTIONS_FILE")
    LITELLM_MODEL_NAME=$(jq -r '.litellm_model_name // empty' "$OPTIONS_FILE")
    TIMEZONE=$(jq -r '.timezone // "America/Los_Angeles"' "$OPTIONS_FILE")

    export TZ="${TIMEZONE}"

    if [ -n "$GATEWAY_TOKEN" ]; then
        export OPENCLAW_GATEWAY_TOKEN="${GATEWAY_TOKEN}"
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

    # Generate openclaw.json config
    if [ ! -f "$OPENCLAW_CONFIG" ]; then
        echo "Generating initial OpenClaw configuration..."

        # Start with base config
        CONFIG=$(cat <<'BASECONFIG'
{
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "token"
    },
    "port": 18789,
    "controlUi": {
      "allowInsecureAuth": true,
      "allowedOrigins": ["*"],
      "dangerouslyAllowHostHeaderOriginFallback": true,
      "dangerouslyDisableDeviceAuth": true
    }
  },
  "agents": {
    "defaults": {
      "workspace": "/data/openclaw/workspace",
      "compaction": {
        "mode": "safeguard"
      }
    },
    "list": [
      {
        "id": "main",
        "sandbox": {
          "mode": "off"
        }
      }
    ]
  },
  "plugins": {
    "entries": {
      "bonjour": { "enabled": false }
    }
  }
}
BASECONFIG
)

        # Set gateway bind and token
        CONFIG=$(echo "$CONFIG" | jq --arg bind "$GATEWAY_BIND" '.gateway.bind = $bind')

        if [ -n "$GATEWAY_TOKEN" ]; then
            CONFIG=$(echo "$CONFIG" | jq --arg token "$GATEWAY_TOKEN" '.gateway.auth.token = $token')
        fi

        # Add LiteLLM provider if configured
        if [ -n "$LITELLM_BASE_URL" ] && [ -n "$LITELLM_MODEL_NAME" ]; then
            LITELLM_KEY="${LITELLM_API_KEY:-sk-1234}"
            CONFIG=$(echo "$CONFIG" | jq \
                --arg url "$LITELLM_BASE_URL" \
                --arg key "$LITELLM_KEY" \
                --arg model "$LITELLM_MODEL_NAME" \
                '.models = {
                    "mode": "merge",
                    "providers": {
                        "litellm": {
                            "baseUrl": $url,
                            "apiKey": $key,
                            "api": "openai-completions",
                            "models": [{
                                "id": $model,
                                "name": $model,
                                "reasoning": false,
                                "input": ["text", "image"],
                                "contextWindow": 200000,
                                "maxTokens": 8096
                            }]
                        }
                    }
                } | .agents.defaults.models = { ("\("litellm/" + $model)"): {} } | .agents.defaults.model.primary = ("litellm/" + $model) | .agents.list[0].model = ("litellm/" + $model)')
        fi

        echo "$CONFIG" | jq . > "$OPENCLAW_CONFIG"
        echo "Configuration written to ${OPENCLAW_CONFIG}"
    else
        # Update gateway token and bind on existing config
        if [ -n "$GATEWAY_TOKEN" ]; then
            jq --arg token "$GATEWAY_TOKEN" '.gateway.auth.token = $token' \
                "$OPENCLAW_CONFIG" > "${OPENCLAW_CONFIG}.tmp" \
                && mv "${OPENCLAW_CONFIG}.tmp" "$OPENCLAW_CONFIG"
        fi
        jq --arg bind "$GATEWAY_BIND" '.gateway.bind = $bind' \
            "$OPENCLAW_CONFIG" > "${OPENCLAW_CONFIG}.tmp" \
            && mv "${OPENCLAW_CONFIG}.tmp" "$OPENCLAW_CONFIG"
    fi

    echo "Configuration loaded."
else
    echo "No options file found, running with defaults."
fi

# --- Set up environment for OpenClaw ---
export OPENCLAW_STATE_DIR="${OPENCLAW_DATA}"
export OPENCLAW_CONFIG_PATH="${OPENCLAW_CONFIG}"
export HOME="/home/node"

# Symlink data so openclaw finds it at its default path
mkdir -p /home/node
ln -sfn "${OPENCLAW_DATA}" /home/node/.openclaw

# --- Start OpenClaw ---
echo "Starting OpenClaw gateway..."
exec node /app/dist/cli.js gateway run
