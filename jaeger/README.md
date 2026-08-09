# Jaeger App for Home Assistant

Jaeger all-in-one, packaged as a Home Assistant app for collecting and viewing
distributed traces.

## Features

- Jaeger 2 with the web UI, collector, and query service
- OpenTelemetry OTLP over gRPC and HTTP
- Zipkin trace ingestion
- Remote sampling support
- Multi-architecture images for 64-bit ARM and AMD systems

The default all-in-one deployment uses in-memory storage. Traces are intended for
local development and diagnostics and are lost when the app restarts.

## Installation

Add this repository to Home Assistant and install the Jaeger app.

## Documentation

See [DOCS.md](DOCS.md) for connection details and supported endpoints.
