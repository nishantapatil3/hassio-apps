ARG SEARXNG_IMAGE=searxng/searxng:2026.6.4-e6559c9ad

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
