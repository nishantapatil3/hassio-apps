FROM jaegertracing/jaeger:2.20.0

ARG BUILD_ARCH
ARG BUILD_VERSION

EXPOSE 16686 4317 4318 5778 9411

LABEL \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.description="OpenTelemetry-compatible distributed tracing backend" \
    io.hass.name="Jaeger" \
    io.hass.type="app" \
    io.hass.version="${BUILD_VERSION}" \
    org.opencontainers.image.source="https://github.com/nishantapatil3/hassio-apps"
