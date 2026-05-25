# Home Assistant Add-on: Hermes Agent

![Version](https://img.shields.io/badge/dynamic/yaml?label=Version&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fnishantapatil3%2Fhassio-apps%2Fmain%2Fhermes-agent%2Fconfig.yaml)
![Arch](https://img.shields.io/badge/dynamic/yaml?color=success&label=Arch&query=%24.arch&url=https%3A%2F%2Fraw.githubusercontent.com%2Fnishantapatil3%2Fhassio-apps%2Fmain%2Fhermes-agent%2Fconfig.yaml)

## About

[Hermes Agent](https://github.com/NousResearch/hermes-agent) is an autonomous AI agent with an OpenAI-compatible API by Nous Research. It provides a gateway server and an optional web dashboard for monitoring and chatting with the agent.

## Features

- OpenAI-compatible API gateway (port 8642)
- Web dashboard for monitoring and chat (port 9119)
- Multi-provider support (OpenAI, Anthropic, Google, Groq, Mistral, OpenRouter)
- Persistent sessions, memories, and skills

## Installation

1. Add this repository to your Home Assistant add-on store:
   `https://github.com/nishantapatil3/hassio-apps`
2. Install the **Hermes Agent** add-on
3. Configure your API keys in the add-on options
4. Start the add-on

## Configuration

```yaml
api_server_enabled: true
api_server_key: ""
dashboard_enabled: true
api_keys:
  - name: OPENAI_API_KEY
    value: ""
log_level: info
```

## Access

- API: `http://<your-ha-ip>:8642`
- Dashboard: `http://<your-ha-ip>:9119`
