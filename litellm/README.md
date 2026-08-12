# Home Assistant app: LiteLLM

LiteLLM is an OpenAI-compatible AI gateway. This package adapts the
[litellm-compose](https://github.com/nishantapatil3/litellm-compose) setup for
Home Assistant's single-container app model.

It provides a file-upload guardrail. Provider credentials and models are managed
through the LiteLLM admin UI. The bundled PostgreSQL host is configured through
an app option; custom databases and optional services such as Redis or Prometheus
use `litellm.yaml`.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
