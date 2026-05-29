# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2026-05-29

### Added

- Add free-form `environment_variables` UI option for any LiteLLM/provider env var
- Allow free-form provider API key names instead of a fixed dropdown
- Generate LiteLLM model API keys as `os.environ/<NAME>` references
- Wire `log_level` to `LITELLM_LOG` unless explicitly overridden

## [1.1.9] - 2026-05-20

### Added

- Enable `store_prompts_in_spend_logs` in general_settings for prompt logging in spend logs

---

## [1.1.8] - 2026-05-20

### Removed

- Removed unsupported Home Assistant ingress/sidebar support for the LiteLLM UI
- Removed nginx response rewriting used for ingress path handling

---

## [1.1.0] - 2026-05-20

### Added

- Add-on store presentation files (README.md, CHANGELOG.md)
- Dropdown selector for API key names with common providers
- NVIDIA NIM and OpenRouter API key support

---

## [1.0.0] - 2025-05-20

### Added

- Initial release of the LiteLLM Home Assistant add-on
- OpenAI-compatible proxy for 100+ LLM providers
- Bundled PostgreSQL database for persistence
- Web UI for managing models, keys, and teams
- Structured configuration with separate API keys, model list, and settings
- Support for aarch64 and amd64 architectures
- Tag-based versioning with automated releases
