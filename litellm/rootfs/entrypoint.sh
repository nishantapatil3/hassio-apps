#!/bin/bash
set -euo pipefail

export PATH="/app/.venv/bin:$PATH"
export PYTHONPATH="/app"

# --- Read HA options and build LiteLLM config ---
OPTIONS_FILE="/data/options.json"
if [ -f "$OPTIONS_FILE" ]; then
    echo "Running inside Home Assistant, reading options..."

    # Build and source shell-safe exports from UI options before generating
    # LiteLLM config. This supports arbitrary LiteLLM/provider env vars.
    ENV_EXPORTS_FILE="/tmp/litellm_env_exports.sh"
    python3 << 'PYTHON'
import json
import os
import re
import shlex
import sys

OPTIONS_FILE = "/data/options.json"
ENV_EXPORTS_FILE = "/tmp/litellm_env_exports.sh"
ENV_NAME_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")

with open(OPTIONS_FILE) as f:
    opts = json.load(f)

env = {}

def set_env(name, value, source):
    if name is None:
        return
    name = str(name).strip()
    if not name:
        return
    if not ENV_NAME_RE.match(name):
        print(f"Skipping invalid environment variable name from {source}: {name}", file=sys.stderr)
        return
    if value is None:
        return
    env[name] = str(value)

for entry in opts.get("environment_variables", []):
    set_env(entry.get("name"), entry.get("value"), "environment_variables")

for entry in opts.get("api_keys", []):
    set_env(entry.get("name"), entry.get("value"), "api_keys")

master_key = opts.get("master_key", "")
if master_key:
    env["LITELLM_MASTER_KEY"] = str(master_key)
else:
    env.setdefault("LITELLM_MASTER_KEY", "")

log_level = opts.get("log_level", "")
if log_level:
    env.setdefault("LITELLM_LOG", str(log_level))

with open(ENV_EXPORTS_FILE, "w") as f:
    f.write("# Auto-generated from Home Assistant add-on configuration\n")
    for name, value in env.items():
        f.write(f"export {name}={shlex.quote(value)}\n")

os.chmod(ENV_EXPORTS_FILE, 0o600)
print(f"Prepared {len(env)} environment variables from add-on configuration")
PYTHON

    # shellcheck source=/dev/null
    source "$ENV_EXPORTS_FILE"
    rm -f "$ENV_EXPORTS_FILE"

    # Build config.yaml from structured options
    python3 << 'PYTHON'
import json, yaml, os

with open("/data/options.json") as f:
    opts = json.load(f)

# Build API key name set from API key UI plus generic environment UI.
env_names = set()
for entry in opts.get("api_keys", []):
    if entry.get("name") and os.environ.get(entry["name"], ""):
        env_names.add(entry["name"])
for entry in opts.get("environment_variables", []):
    if entry.get("name") and os.environ.get(entry["name"], ""):
        env_names.add(entry["name"])

# Build model_list in LiteLLM format
model_list = []
for m in opts.get("model_list", []):
    params = {"model": m["model"]}
    key_name = m.get("api_key_name", "")
    if key_name and key_name in env_names:
        params["api_key"] = f"os.environ/{key_name}"
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
if os.environ.get("LITELLM_MASTER_KEY", ""):
    general_settings["master_key"] = "os.environ/LITELLM_MASTER_KEY"
else:
    general_settings["master_key"] = ""
config["general_settings"] = general_settings

os.makedirs("/etc/litellm", exist_ok=True)
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
