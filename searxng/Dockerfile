ARG SEARXNG_IMAGE=searxng/searxng:2026.5.30-01159b82f

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
