# Changelog

## 0.5.0

- All hermes settings now configurable from the HA add-on Configuration page
- Added fields: model/provider, max turns, reasoning effort, memory, compression,
  terminal backend, language, API timeout, YOLO mode, web search backend
- Added search tool API keys: Tavily, Firecrawl, Exa, SearXNG URL
- Entrypoint generates .env and config.yaml from HA options on every start

## 0.4.0

- `.env` is now the single source of truth for all hermes configuration
- `.env` editable via HA File Editor at `addon_configs/hermes-agent/.env`
- Start hermes dashboard as background process (port 9119)
- Simplify config UI to just `api_server_key` and provider API keys
- First boot generates `.env` from config UI; subsequent runs use the file directly

## 0.3.1

- Expose Hermes dashboard Web UI in HA sidebar ("Open Web UI" button)
- Update icon

## 0.3.0

- Make .env editable via HA File Editor (addon_configs)
- User-edited .env takes priority over config UI options
- Add logo and icon

## 0.2.1

- Allow gateway to run as root (required for HA add-on environment)
- Add `api_server_key` and `gateway_allow_all_users` to config UI
- Default `api_server_key` to `hermesagent`
- Write all config UI options into hermes .env file

## 0.2.0

- Fix entrypoint to use correct `hermes` binary from upstream venv
- Add `HERMES_HOME` for persistent data storage
- Add repo name to GHCR image paths

## 0.1.0

- Initial release
- Gateway mode with OpenAI-compatible API
- Dashboard support
- Configurable API keys for multiple providers

