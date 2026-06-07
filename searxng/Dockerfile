ARG SEARXNG_IMAGE=searxng/searxng:2026.6.7-70de3cc56

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
