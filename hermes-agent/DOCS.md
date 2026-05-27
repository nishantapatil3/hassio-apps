# Home Assistant Add-on: Hermes Agent

## Overview

Hermes Agent is an autonomous AI agent by Nous Research that provides an
OpenAI-compatible API gateway with a built-in web dashboard.

## Configuration

All settings are configurable from the add-on's **Configuration** tab in
Home Assistant (Settings > Add-ons > Hermes Agent > Configuration).

### Model Settings

- **Default Model**: The LLM model to use (e.g. `anthropic/claude-sonnet-4-20250514`,
  `openai/gpt-4o`, `openrouter/anthropic/claude-sonnet-4-20250514`)
- **Model Provider**: Which provider serves the model

### Agent Behavior

- **Max Turns**: Maximum iterations per session (default: 90)
- **Reasoning Effort**: How much reasoning the model applies (empty = default)
- **YOLO Mode**: Skip all safety approval prompts
- **Memory Enabled**: Persist memories across sessions
- **Compression**: Compress context when approaching token limits

### Gateway & Dashboard

- **API Server Key**: Bearer token for API authentication (min 8 chars)
- **Allow All Users**: Skip user authentication on the gateway
- **Dashboard Enabled**: Enable the web dashboard on port 9119

### Web Search

- **Web Search Backend**: Choose firecrawl, searxng, tavily, exa, or parallel
- **SearXNG URL**: URL for self-hosted SearXNG instance

### API Keys

Configure provider keys (OpenAI, Anthropic, Google, Groq, Mistral, OpenRouter)
and tool-specific keys (Tavily, Firecrawl, Exa) directly in the Configuration tab.

## Data Persistence

All agent state (sessions, memories, skills) is stored in `/data/hermes/`
which persists across add-on restarts and updates.

## API Usage

The gateway exposes an OpenAI-compatible API on port 8642:

```
http://<your-ha-host>:8642
```

## More Information

- [Hermes Configuration Reference](https://hermes-agent.nousresearch.com/docs/user-guide/configuration)
- [Hermes Agent Documentation](https://hermes-agent.nousresearch.com/docs/user-guide/docker)
- [Nous Research](https://nousresearch.com)
