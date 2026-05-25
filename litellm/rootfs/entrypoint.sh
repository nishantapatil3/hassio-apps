#!/bin/bash
set -e

export PATH="/app/.venv/bin:$PATH"
export PYTHONPATH="/app"

# --- Read HA options and build LiteLLM config ---
OPTIONS_FILE="/data/options.json"
if [ -f "$OPTIONS_FILE" ]; then
    echo "Running inside Home Assistant, reading options..."

    MASTER_KEY=$(jq -r '.master_key // empty' "$OPTIONS_FILE")
    export LITELLM_MASTER_KEY="${MASTER_KEY}"

    # Build config.yaml from structured options
    python3 << 'PYTHON'
import json, yaml, os

with open("/data/options.json") as f:
    opts = json.load(f)

# Build API key lookup from api_keys list
api_keys = {}
for entry in opts.get("api_keys", []):
    if entry.get("name") and entry.get("value"):
        api_keys[entry["name"]] = entry["value"]

# Build model_list in LiteLLM format
model_list = []
for m in opts.get("model_list", []):
    params = {"model": m["model"]}
    # Resolve api_key from the api_keys map
    key_name = m.get("api_key_name", "")
    if key_name and key_name in api_keys:
        params["api_key"] = api_keys[key_name]
    if m.get("api_base"):
        params["api_base"] = m["api_base"]
    model_list.append({
        "model_name": m["model_name"],
        "litellm_params": params,
    })

# Assemble the full config
config = {"model_list": model_list}

litellm_settings = opts.get("litellm_settings", {})
if litellm_settings:
    config["litellm_settings"] = litellm_settings

general_settings = opts.get("general_settings", {})
general_settings["master_key"] = os.environ.get("LITELLM_MASTER_KEY", "")
config["general_settings"] = general_settings

with open("/etc/litellm/config.yaml", "w") as f:
    yaml.dump(config, f, default_flow_style=False)

print("Generated /etc/litellm/config.yaml")
PYTHON

else
    # Standalone docker run — use default config
    export LITELLM_MASTER_KEY="${LITELLM_MASTER_KEY:-sk-1234}"
fi

# --- PostgreSQL Setup ---
mkdir -p /data/postgres /run/postgresql
if ! id postgres &>/dev/null; then
    adduser -D -h /var/lib/postgresql -s /bin/sh postgres
fi
chown -R postgres:postgres /data/postgres /run/postgresql

if [ ! -f /data/postgres/PG_VERSION ]; then
    echo "Initializing PostgreSQL database..."
    su - postgres -c "initdb -D /data/postgres" 2>&1 | tail -3

    cat > /data/postgres/pg_hba.conf << 'EOF'
local all all trust
host all all 127.0.0.1/32 trust
EOF

    echo "unix_socket_directories = '/run/postgresql'" >> /data/postgres/postgresql.conf
    echo "listen_addresses = '127.0.0.1'" >> /data/postgres/postgresql.conf

    su - postgres -c "pg_ctl start -D /data/postgres -w"
    su - postgres -c "psql -h 127.0.0.1 -c \"CREATE USER litellm WITH PASSWORD 'litellm';\""
    su - postgres -c "psql -h 127.0.0.1 -c \"CREATE DATABASE litellm OWNER litellm;\""
else
    su - postgres -c "pg_ctl start -D /data/postgres -w"
fi

echo "PostgreSQL is ready."

# --- Environment ---
export DATABASE_URL="${DATABASE_URL:-postgresql://litellm:litellm@127.0.0.1:5432/litellm}"
export STORE_MODEL_IN_DB="${STORE_MODEL_IN_DB:-True}"

# --- Prisma Migrations ---
cd /app
./docker/entrypoint.sh

# --- Start LiteLLM ---
echo "Starting LiteLLM..."
exec litellm --config /etc/litellm/config.yaml "$@"
