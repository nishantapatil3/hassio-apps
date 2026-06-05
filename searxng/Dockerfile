ARG SEARXNG_IMAGE=searxng/searxng:2026.6.5-007a4e215

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
