FROM docker.litellm.ai/berriai/litellm:main-stable

ARG BUILD_ARCH
ARG BUILD_VERSION

USER root

COPY rootfs /

RUN chmod 0755 /usr/local/bin/litellm-addon

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["python3", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:4000/health/liveliness', timeout=5)"]

LABEL \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.description="AI gateway for Claude Code and Claude Desktop" \
    io.hass.name="LiteLLM" \
    io.hass.type="app" \
    io.hass.version="${BUILD_VERSION}" \
    org.opencontainers.image.source="https://github.com/nishantapatil3/hassio-apps"

ENTRYPOINT ["/usr/local/bin/litellm-addon"]
