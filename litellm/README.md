# Home Assistant Add-on: LiteLLM

OpenAI-compatible proxy for 100+ LLM providers — run a unified API gateway
for OpenAI, Anthropic, Google, Azure, Ollama, and more directly from
Home Assistant.

Features:

- Single endpoint for all LLM providers
- Virtual API key management with budgets and rate limits
- Load balancing and fallbacks across models
- Usage tracking and analytics
- Web dashboard for administration
- Bundled PostgreSQL for data persistence

Access:

- API: `http://<your-ha-ip>:4000`
- Admin UI: `http://<your-ha-ip>:4000/ui`

Home Assistant sidebar/ingress access is not enabled. LiteLLM's dynamic Admin
UI does not reliably support Home Assistant's dynamic ingress base path without
brittle response rewriting.
