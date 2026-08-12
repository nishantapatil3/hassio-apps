FROM docker.io/cognee/cognee:main@sha256:0c6f545994fcd5b5db4e4fe1d53133dc40320ef2f3b48220ada24dfcf462b27c

ARG BUILD_ARCH
ARG BUILD_VERSION

USER root
COPY rootfs /

RUN chmod 0755 /usr/local/bin/cognee-addon

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD ["curl", "--fail", "--silent", "http://127.0.0.1:8000/"]

LABEL \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.description="Self-hosted AI memory and knowledge graph API" \
    io.hass.name="Cognee" \
    io.hass.type="app" \
    io.hass.version="${BUILD_VERSION}" \
    org.opencontainers.image.source="https://github.com/nishantapatil3/hassio-apps"

ENTRYPOINT ["/usr/local/bin/cognee-addon"]
