ARG SEARXNG_IMAGE=searxng/searxng:2026.6.2-e964708c0

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
