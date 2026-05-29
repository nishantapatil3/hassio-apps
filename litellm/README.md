# Home Assistant Add-on: LiteLLM

![Version](https://img.shields.io/badge/dynamic/yaml?label=Version&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fnishantapatil3%2Fhassio-apps%2Fmain%2Flitellm%2Fconfig.yaml)
![Arch](https://img.shields.io/badge/dynamic/yaml?color=success&label=Arch&query=%24.arch&url=https%3A%2F%2Fraw.githubusercontent.com%2Fnishantapatil3%2Fhassio-apps%2Fmain%2Flitellm%2Fconfig.yaml)

## About

[LiteLLM](https://github.com/BerriAI/litellm) is an OpenAI-compatible proxy for 100+ LLM providers. Run a unified API gateway for OpenAI, Anthropic, Google, Azure, Ollama, and more directly from Home Assistant.

## Features

- Single endpoint for all LLM providers
- Virtual API key management with budgets and rate limits
- Load balancing and fallbacks across models
- Usage tracking and analytics
- Web dashboard for administration
- Bundled PostgreSQL for data persistence

## Installation

1. Add this repository to your Home Assistant add-on store:
   `https://github.com/nishantapatil3/hassio-apps`
2. Install the **LiteLLM** add-on
3. Configure your master key and API keys in the add-on options
4. Start the add-on

## Configuration

```yaml
master_key: ""
api_keys:
  - name: OPENAI_API_KEY
    value: ""
model_list:
  - model_name: gpt-4
    model: openai/gpt-4
    api_key_name: OPENAI_API_KEY
environment_variables:
  - name: LITELLM_LOG
    value: info
log_level: info
```

`api_keys` and `environment_variables` both accept free-form environment
variable names, so provider-specific LiteLLM options can be configured directly
from the Home Assistant UI.

## Access

- API: `http://<your-ha-ip>:4000`
- Admin UI: `http://<your-ha-ip>:4000/ui`

Home Assistant sidebar/ingress access is not enabled. LiteLLM's dynamic Admin UI does not reliably support Home Assistant's ingress base path.
