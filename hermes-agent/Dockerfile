ARG HERMES_IMAGE=nousresearch/hermes-agent:latest

# hadolint ignore=DL3006
FROM ${HERMES_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,DL3015
RUN apt-get update && apt-get install -y --no-install-recommends \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Copy root filesystem (s6-overlay services + init scripts)
COPY rootfs /

ENV HERMES_DATA_DIR="/data/hermes"

EXPOSE 8642 9119

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["gateway", "run"]
