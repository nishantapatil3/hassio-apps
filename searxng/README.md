# Home Assistant Add-on: SearXNG

![Version](https://img.shields.io/badge/dynamic/yaml?label=Version&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fnishantapatil3%2Fhassio-apps%2Fmain%2Fsearxng%2Fconfig.yaml)
![Ingress](https://img.shields.io/badge/dynamic/yaml?label=Ingress&query=%24.ingress&url=https%3A%2F%2Fraw.githubusercontent.com%2Fnishantapatil3%2Fhassio-apps%2Fmain%2Fsearxng%2Fconfig.yaml)
![Arch](https://img.shields.io/badge/dynamic/yaml?color=success&label=Arch&query=%24.arch&url=https%3A%2F%2Fraw.githubusercontent.com%2Fnishantapatil3%2Fhassio-apps%2Fmain%2Fsearxng%2Fconfig.yaml)

## About

[SearXNG](https://docs.searxng.org/index.html) is a privacy-respecting
metasearch engine that aggregates results from many search services without
tracking or profiling users.

This add-on is based on the SearXNG add-on from
[DDanii/HA-Add-ons-by-DDanii](https://github.com/DDanii/HA-Add-ons-by-DDanii/tree/master/searxng).

## Installation

1. Add this repository to your Home Assistant add-on store:
   `https://github.com/nishantapatil3/hassio-apps`
2. Install the **SearXNG** add-on
3. Start the add-on
4. Open it from the add-on page or the Home Assistant sidebar

## Configuration

```yaml
set_base_url_for_ingress: true
```

When `set_base_url_for_ingress` is enabled, the add-on sets
`SEARXNG_BASE_URL` to the Home Assistant ingress URL so SearXNG works from the
sidebar.

SearXNG settings can be customized in the add-on configuration folder. Inside
the add-on this folder is mounted at `/etc/searxng`; in Home Assistant it is
exposed under `addon_configs/<repository>_searxng`.

After the first run, the add-on creates `custom.sh` in that folder. You can use
it to run custom commands before SearXNG starts.

## Access

- Ingress/sidebar: enabled
- Web UI: `http://<your-ha-ip>:8080`
