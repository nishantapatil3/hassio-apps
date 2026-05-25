ARG OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:latest

# hadolint ignore=DL3006
FROM ${OPENCLAW_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,DL3015
RUN apt-get update && apt-get install -y --no-install-recommends \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Copy root filesystem
COPY rootfs /

EXPOSE 18789

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
