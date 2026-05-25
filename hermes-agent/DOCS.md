# Home Assistant Add-on: Hermes Agent

## Overview

Hermes Agent is an autonomous AI agent by Nous Research that provides an
OpenAI-compatible API gateway with a built-in web dashboard.

## Configuration

### API Server Key

Set an authentication key (minimum 8 characters) that clients must provide
as a Bearer token when calling the API. Leave empty to disable authentication.

### API Keys

Configure provider API keys that Hermes Agent will use to connect to LLM
backends (OpenAI, Anthropic, Google, etc.).

### Dashboard

When enabled, the dashboard is available at port 9119 and provides monitoring
and a chat interface to interact with the agent.

## Data Persistence

All agent state (sessions, memories, skills) is stored in `/data/hermes/`
which persists across add-on restarts and updates.

## API Usage

The gateway exposes an OpenAI-compatible API on port 8642. Use it with any
OpenAI-compatible client by pointing the base URL to:

```
http://<your-ha-host>:8642
```

## More Information

- [Hermes Agent Documentation](https://hermes-agent.nousresearch.com/docs/user-guide/docker)
- [Nous Research](https://nousresearch.com)
