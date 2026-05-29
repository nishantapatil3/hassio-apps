#!/bin/sh

set -eu

set_url="$(grep '"set_base_url_for_ingress"' /data/options.json | cut -d: -f2 | xargs)"

if [ "${set_url}" = "true" ]; then
    header="Authorization: Bearer ${SUPERVISOR_TOKEN}"
    SEARXNG_BASE_URL="$(wget -qO- --header="${header}" \
        "http://supervisor/addons/self/info" \
        | sed -n 's/.*"ingress_url":"\([^"]*\)".*/\1/p')"
    export SEARXNG_BASE_URL
fi

if [ ! -f /etc/searxng/custom.sh ]; then
    cp /custom.sh /etc/searxng/custom.sh
fi

chmod +x /etc/searxng/custom.sh

exec /etc/searxng/custom.sh
