# Home Assistant Add-on: LiteLLM

[![License][license-shield]](LICENSE.md)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[LiteLLM](https://github.com/BerriAI/litellm) proxy server as a
Home Assistant add-on. Provides a unified OpenAI-compatible API gateway
for 100+ LLM providers.

## About

This add-on packages the LiteLLM proxy with a bundled PostgreSQL database
for Home Assistant. It enables:

- **Unified API**: Single OpenAI-compatible endpoint for all LLM providers
- **Multiple Providers**: OpenAI, Anthropic, Google, Azure, Ollama, Groq, and more
- **Key Management**: Virtual API keys with per-key budgets and rate limits
- **Load Balancing**: Route across multiple models with fallbacks
- **Usage Tracking**: Monitor spend and usage per key/team/model
- **Web Dashboard**: Manage models, keys, and teams via UI

## Supported Access

The LiteLLM API and Admin UI are exposed directly on port `4000`:

- API: `http://<your-ha-ip>:4000`
- Admin UI: `http://<your-ha-ip>:4000/ui`

Home Assistant sidebar/ingress access is intentionally not enabled. LiteLLM's
dynamic Admin UI does not reliably support Home Assistant's dynamic ingress
base path without brittle response rewriting.

## Installation

1. Add this repository URL to your Home Assistant add-on store:
   ```
   https://github.com/nishantapatil3/hassio-app-litellm
   ```
2. Find "LiteLLM" in the add-on store and click Install.
3. Configure your models and API keys in the Configuration tab.
4. Start the add-on.
5. Access the proxy at `http://<your-ha-ip>:4000`.

## Documentation

See the [full documentation](litellm/DOCS.md) for configuration examples
and usage instructions.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[license-shield]: https://img.shields.io/github/license/nishantapatil3/hassio-app-litellm.svg
