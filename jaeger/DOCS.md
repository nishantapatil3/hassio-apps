# Jaeger App Documentation

Jaeger provides distributed tracing collection and a web UI. The app runs the
official Jaeger 2 all-in-one image with in-memory trace storage.

## Storage

Trace data is transient and is cleared whenever the app restarts or updates. This
app is intended for local development and diagnostics. Persistent storage requires
a custom Jaeger configuration and is not exposed as an app option.

## Connecting

Open the Jaeger web UI at:

```text
http://homeassistant.local:16686
```

Configure instrumented applications to send traces to one of these endpoints:

- OTLP over gRPC: `homeassistant.local:4317`
- OTLP over HTTP: `http://homeassistant.local:4318`
- Zipkin: `http://homeassistant.local:9411/api/v2/spans`

The host ports can be changed in the app Network settings. When an application
runs in another Home Assistant app, use the app's internal hostname and the
corresponding container port instead.

Remote sampling is available at:

```text
http://homeassistant.local:5778/sampling
```
