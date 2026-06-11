ARG SEARXNG_IMAGE=searxng/searxng:2026.6.11-a1490676e

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
