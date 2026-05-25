# Home Assistant Add-on: OpenClaw

## Overview

OpenClaw is an AI agent gateway that provides a web UI for interacting with
LLM-powered agents. It supports multiple model providers and can integrate
with a LiteLLM proxy for unified model access.

## Configuration

### Gateway Token

Authentication token for WebSocket connections. Clients connect using:
- URL fragment: `http://<host>:18789/#token=<token>`
- Manual paste in Settings > Auth

Leave empty for auto-generation on first start.

### Gateway Bind

- **lan**: Accept connections from your local network (recommended for HA)
- **loopback**: Only accept connections from localhost

### API Keys

Configure provider API keys (OpenAI, Anthropic, Gemini, etc.) that OpenClaw
will use to call LLM APIs directly.

### LiteLLM Integration

If you're running the LiteLLM add-on, you can point OpenClaw at it:
- Set **LiteLLM Base URL** to `http://homeassistant.local:4000`
- Set **LiteLLM API Key** to your LiteLLM master key
- Set **LiteLLM Model Name** to the model you configured in LiteLLM

## Data Persistence

All state (config, workspace, sessions) is stored in `/data/openclaw/`
which persists across add-on restarts and updates.

## Web UI

The web UI is accessible at port 18789. On first access you'll need to
authenticate with the gateway token.

## More Information

- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
