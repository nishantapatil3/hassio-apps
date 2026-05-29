ARG SEARXNG_IMAGE=searxng/searxng:2026.5.29-4ea5c57a8

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
