ARG SEARXNG_IMAGE=searxng/searxng:2026.6.11-4dd0bf486

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
