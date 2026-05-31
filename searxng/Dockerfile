ARG SEARXNG_IMAGE=searxng/searxng:2026.5.31-7159b8aed

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
