ARG SEARXNG_IMAGE=searxng/searxng:2026.5.23-323ce7600

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
