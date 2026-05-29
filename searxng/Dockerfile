ARG SEARXNG_IMAGE=searxng/searxng:2026.5.26-0037d43d8

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
