ARG SEARXNG_IMAGE=searxng/searxng:2026.6.14-b3e08f2a4

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
