# Home Assistant Add-on: LiteLLM

## About

[LiteLLM](https://github.com/BerriAI/litellm) is an OpenAI-compatible proxy
that routes requests to 100+ LLM providers (OpenAI, Anthropic, Google, Azure,
Ollama, and more) through a single unified API.

This add-on runs the LiteLLM proxy server with a bundled PostgreSQL database,
giving you full access to features like:

- Unified OpenAI-compatible API for all providers
- Virtual API key management
- Team and organization budgets
- Usage tracking and analytics
- Load balancing and fallbacks across models
- Web UI for managing models and keys

## Installation

1. Add this repository to your Home Assistant add-on store.
2. Install the "LiteLLM" add-on.
3. Configure your models and API keys in the Configuration tab.
4. Start the add-on.

## Configuration

### Option: `master_key`

The authentication key for accessing the LiteLLM proxy API. All requests must
include this as a Bearer token in the Authorization header.

Example: `sk-my-secret-key-1234`

Leave empty to disable authentication (not recommended for production).

### Option: `log_level`

Controls the verbosity of the add-on logs. Valid values:
`trace`, `debug`, `info`, `notice`, `warning`, `error`, `fatal`.

### Option: `api_keys`

Provider API keys to export as environment variables before LiteLLM starts.
Names are free-form, so you can use any variable LiteLLM or an upstream SDK
supports, such as `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`,
`OPENROUTER_API_KEY`, `DEEPSEEK_API_KEY`, or cloud provider credentials.

Model entries reference these keys with `api_key_name`; the generated LiteLLM
config uses `os.environ/<NAME>` so secret values are not written into
`config.yaml`.

### Option: `environment_variables`

Additional environment variables to export before LiteLLM starts. Use this for
any LiteLLM, provider, proxy, cloud credential, or SDK option that is not a
direct model API key.

```yaml
environment_variables:
  - name: LITELLM_LOG
    value: info
  - name: OPENAI_API_BASE
    value: https://api.openai.com/v1
  - name: AWS_REGION_NAME
    value: us-east-1
```

Environment variable precedence is:

1. `environment_variables`
2. `api_keys`
3. `master_key`, when set, writes `LITELLM_MASTER_KEY`

The `log_level` option writes `LITELLM_LOG` only when `LITELLM_LOG` is not
already set in `environment_variables`.

### Generated `config.yaml`

The full LiteLLM proxy configuration in YAML format. This is where you define
your model list, provider API keys, routing settings, and more.

#### Basic example with OpenAI

```yaml
model_list:
  - model_name: gpt-4
    litellm_params:
      model: openai/gpt-4
      api_key: sk-your-openai-key
litellm_settings:
  drop_params: true
  telemetry: false
general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY
  store_model_in_db: true
```

#### Multiple providers

```yaml
model_list:
  - model_name: gpt-4
    litellm_params:
      model: openai/gpt-4
      api_key: sk-openai-key
  - model_name: claude-sonnet
    litellm_params:
      model: anthropic/claude-sonnet-4-20250514
      api_key: sk-ant-your-key
  - model_name: gemini-pro
    litellm_params:
      model: gemini/gemini-pro
      api_key: your-google-key
  - model_name: local-llama
    litellm_params:
      model: ollama/llama3
      api_base: http://192.168.1.100:11434
litellm_settings:
  drop_params: true
  telemetry: false
general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY
  store_model_in_db: true
```

#### Using environment variable references

You can reference environment variables in the config using the
`os.environ/VARIABLE_NAME` syntax. The `LITELLM_MASTER_KEY` variable is
automatically set from the `master_key` option.

## Usage

Once running, the LiteLLM proxy is available at:

```
http://<your-ha-ip>:4000
```

Supported access:

- API: `http://<your-ha-ip>:4000`
- Admin UI: `http://<your-ha-ip>:4000/ui`
- Add-on Web UI button: opens the direct Admin UI URL above

Home Assistant sidebar/ingress access is intentionally not enabled. LiteLLM's
dynamic Admin UI does not reliably support Home Assistant's dynamic ingress
base path without brittle response rewriting.

### Web UI

Access the admin dashboard at `http://<your-ha-ip>:4000/ui` to manage models,
virtual keys, teams, and view usage analytics.

### API

The proxy exposes an OpenAI-compatible API:

```bash
curl http://<your-ha-ip>:4000/v1/chat/completions \
  -H "Authorization: Bearer your-master-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Health Check

```bash
curl http://<your-ha-ip>:4000/health/liveliness
```

## Network

| Port   | Description             |
|--------|-------------------------|
| 4000   | LiteLLM Proxy API & UI  |

## Data Persistence

All data is stored in `/data/litellm/`:
- `config.yaml` — Active LiteLLM configuration
- `postgres/` — PostgreSQL database files
- `.db_password` — Auto-generated database password

Data persists across add-on restarts and updates.

## Support

Got questions? Open an issue at:
<https://github.com/nishantapatil3/hassio-app-litellm/issues>
