# LiteLLM

## Setup

1. Install and start the add-on.
2. Install and start the PostgreSQL add-on from this repository.
   The default uses its internal Home Assistant hostname.
3. On first start the add-on writes a default `litellm.yaml` to the config folder
   and stops with instructions.
4. In the add-on Configuration page, set:
   - `master_key` — a strong key starting with `sk-` (clients use this to authenticate).
   - `database_host` — the PostgreSQL hostname, defaulting to the bundled add-on.
5. Restart the add-on.
6. Open the LiteLLM admin UI, then add your provider credentials and models.

For Claude Code, set `ANTHROPIC_BASE_URL` to `http://HOME_ASSISTANT_IP:4000`
and `ANTHROPIC_API_KEY` to your configured `master_key`.

## Configuration

Most connection settings are available in the add-on Configuration page. Advanced
LiteLLM settings live in:

```
/addon_configs/a1fb5371_litellm/litellm.yaml
```

Edit this file directly and restart the add-on to apply advanced changes. It is
a standard [LiteLLM proxy configuration](https://docs.litellm.ai/docs/proxy/configs).

Redis caching, Prometheus metrics, SearXNG, and other advanced LiteLLM features
can be configured directly in this file.

## PostgreSQL (bundled default)

PostgreSQL is used for the admin UI, virtual keys, and spend tracking.

The PostgreSQL add-on in this repository ensures the `litellm` database exists
on every start. LiteLLM builds its connection URL from `database_host` using the
bundled PostgreSQL defaults:

```text
postgresql://postgres:homeassistant@db21ed7f-postgres:5432/litellm
```

Set `database_host` to a different hostname if the add-on hostname differs. For
custom ports or credentials, set `general_settings.database_url` directly in
`litellm.yaml` instead.

## Redis (optional)

Redis response caching is disabled by default. To enable it, add LiteLLM's
`cache` and `cache_params` settings directly to `litellm.yaml`.

## Endpoints

| Path | Purpose |
| --- | --- |
| `http://HOME_ASSISTANT_IP:4000` | API base |
| `http://HOME_ASSISTANT_IP:4000/ui` | Admin UI (login: `admin` / `master_key`) |
| `http://HOME_ASSISTANT_IP:4000/health/liveliness` | Health check |

## Models

No models or provider credentials are configured by default. Add them in the
LiteLLM admin UI; they are persisted in PostgreSQL.

The add-on stores application home, XDG configuration, data, state, and ChatGPT
device-login credentials in its persistent data directory. Provider credentials
and settings written to these standard locations survive restarts and upgrades.
The first request to a `chatgpt/` model prompts for device authentication if no
valid credentials are stored.

The file guardrail rejects file and document content blocks before a model call.

## Security

Port 4000 is exposed on the local network. Use a strong master key, keep API
keys private, and place LiteLLM behind a trusted HTTPS reverse proxy before
making it reachable from the internet.
