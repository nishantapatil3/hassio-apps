# Changelog

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

