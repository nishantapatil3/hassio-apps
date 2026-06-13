ARG SEARXNG_IMAGE=searxng/searxng:2026.6.13-b48205b38

FROM ${SEARXNG_IMAGE}

COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
