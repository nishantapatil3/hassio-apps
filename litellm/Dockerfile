ARG LITELLM_IMAGE=ghcr.io/berriai/litellm-database:main-stable

# hadolint ignore=DL3006
FROM ${LITELLM_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install PostgreSQL
# hadolint ignore=DL3018
RUN apk add --no-cache \
        postgresql-16 \
        postgresql-16-client \
        jq

# Ensure venv is on PATH
ENV PATH="/app/.venv/bin:${PATH}" \
    PYTHONPATH="/app"

# Copy root filesystem (config + startup script)
COPY rootfs /

EXPOSE 4000

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["--port", "4000", "--host", "0.0.0.0"]
