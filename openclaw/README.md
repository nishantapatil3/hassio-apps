# Home Assistant Add-on: OpenClaw

![Version](https://img.shields.io/badge/dynamic/yaml?label=Version&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fnishantapatil3%2Fhassio-apps%2Fmain%2Fopenclaw%2Fconfig.yaml)
![Arch](https://img.shields.io/badge/dynamic/yaml?color=success&label=Arch&query=%24.arch&url=https%3A%2F%2Fraw.githubusercontent.com%2Fnishantapatil3%2Fhassio-apps%2Fmain%2Fopenclaw%2Fconfig.yaml)

## About

[OpenClaw](https://github.com/open-claw/open-claw) is an AI agent gateway with a built-in web interface for interacting with LLM-powered agents. It supports direct provider API keys and can integrate with LiteLLM for unified model routing.

## Features

- Web-based chat UI with agent interaction (port 18789)
- Multi-provider support (OpenAI, Anthropic, Gemini, OpenRouter, Google)
- LiteLLM proxy integration for unified model access
- Persistent sessions and workspace
- Configurable gateway authentication

## Installation

1. Add this repository to your Home Assistant add-on store:
   `https://github.com/nishantapatil3/hassio-apps`
2. Install the **OpenClaw** add-on
3. Configure your API keys in the add-on options
4. Start the add-on

## Configuration

```yaml
gateway_token: ""
gateway_bind: lan
api_keys:
  - name: OPENAI_API_KEY
    value: ""
litellm_base_url: ""
litellm_api_key: ""
litellm_model_name: ""
timezone: America/Los_Angeles
```

## Access

- Web UI: `http://<your-ha-ip>:18789`
