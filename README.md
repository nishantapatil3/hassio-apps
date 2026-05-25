# Home Assistant Add-on Repository

[![License][license-shield]](LICENSE.md)

## Add-ons

This repository contains the following Home Assistant add-ons:

### [LiteLLM](litellm/)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

OpenAI-compatible proxy for 100+ LLM providers with a bundled PostgreSQL
database, web dashboard, key management, and usage tracking.

- **Port 4000** — API & Admin UI

### [Hermes Agent](hermes-agent/)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Autonomous AI agent with OpenAI-compatible API by Nous Research. Includes
a web dashboard for monitoring and chatting with the agent.

- **Port 8642** — Gateway API
- **Port 9119** — Dashboard

### [OpenClaw](openclaw/)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

AI agent gateway with web UI by OpenClaw. Supports multiple model providers
and integrates with LiteLLM for unified model routing.

- **Port 18789** — Gateway & Web UI

## Installation

1. Add this repository URL to your Home Assistant add-on store:
   ```
   https://github.com/nishantapatil3/hassio-apps
   ```
2. Find the add-on you want in the store and click **Install**.
3. Configure via the **Configuration** tab.
4. Start the add-on.

## License

See [LICENSE.md](LICENSE.md).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[license-shield]: https://img.shields.io/github/license/nishantapatil3/hassio-apps.svg
