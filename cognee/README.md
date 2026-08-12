# Home Assistant app: Cognee

Cognee is an open-source AI memory platform for agents. This app runs the
official multi-architecture Cognee API image with persistent embedded databases.

## Features

- Official Cognee API image for aarch64 and amd64
- Persistent SQLite, LanceDB, and Kuzu knowledge stores
- Configurable LLM and embedding providers
- Authenticated multi-user API with per-dataset isolation
- Interactive OpenAPI documentation

## Installation

Add this repository to Home Assistant and install the Cognee app. Configure the
LLM API key and provider settings, start the app, then open its Web UI.

See [DOCS.md](DOCS.md) for configuration and API usage details.

[upstream]: https://github.com/topoteretes/cognee
