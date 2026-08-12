# Cognee

Cognee provides persistent memory, semantic search, and knowledge graphs for AI
agents. The app exposes the Cognee REST API and stores all embedded database
files in the Home Assistant app configuration directory.

## First start

1. Open the app **Configuration** page.
2. Enter `llm_api_key` for your selected LLM provider.
3. Confirm the model, provider, and embedding settings.
4. Start the app and open the Web UI for interactive API documentation.

The defaults use OpenAI for both generation and embeddings. For an
OpenAI-compatible provider, set `llm_provider`, `llm_model`, and `llm_endpoint`
as required by that provider. Configure the embedding settings separately when
the provider does not supply OpenAI embeddings.

## Authentication

Authentication and dataset isolation are enabled. Register the first user with
`POST /api/v1/auth/register`, log in with `POST /api/v1/auth/login`, and use the
returned bearer token. API keys can be managed through `/api/v1/auth` after
login. Interactive request schemas are available at `/docs`.

The app generates signing secrets during its first start and retains them in
the app configuration directory. API keys are stored as hashes. Local host file
paths are rejected; upload data through the API instead.

## API access

The API is available on port `8000`. Cognee supports operations including:

- `POST /api/v1/remember` to create durable memory
- `POST /api/v1/recall` to retrieve relevant memory
- `POST /api/v1/add` and `POST /api/v1/cognify` for ingestion pipelines
- `POST /api/v1/search` to query processed datasets
- `DELETE /api/v1/forget` to remove memory

Keep the port on a trusted network or place it behind an authenticated reverse
proxy. Set `cors_allowed_origins` to a comma-separated allowlist when browser
clients do not require the default wildcard.

The container liveness probe checks the API root. Cognee's `/health` endpoint
performs deeper relational, vector, graph, and LLM checks and can report a
failure when a configured provider or a required extension download is
unavailable.

## Persistence and backup

Relational metadata, vectors, graph data, caches, and authentication secrets are
stored below `/data/cognee`. Cold Home Assistant app backups include this state.
Stop the app before manually copying its files, and never run two Cognee
instances against the same directory.

The image is pinned to a tested upstream build. App upgrades retain the mounted
state and run Cognee's database migrations during startup.

For provider-specific values and API examples, see the [Cognee documentation][docs].

[docs]: https://docs.cognee.ai/
