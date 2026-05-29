# Home Assistant Add-on: SearXNG

## Overview

SearXNG is a privacy-respecting metasearch engine that aggregates results from
many search services without tracking or profiling users.

## Configuration

All settings are configurable from the add-on's **Configuration** tab in Home
Assistant.

### Set Base URL for Ingress

Keep `set_base_url_for_ingress` enabled when using the Home Assistant sidebar
or ingress view. The add-on reads the Home Assistant ingress URL from the
Supervisor API and sets `SEARXNG_BASE_URL` before SearXNG starts.

```yaml
set_base_url_for_ingress: true
```

## SearXNG Settings

SearXNG creates `settings.yml` on first start in the add-on configuration
folder. Inside the container, this folder is mounted at:

```text
/etc/searxng
```

In Home Assistant, the same files are exposed under:

```text
addon_configs/<repository>_searxng
```

Edit `settings.yml` there to customize engines, UI behavior, limiter settings,
or outgoing proxy settings.

## Custom Startup Commands

On first start, the add-on creates `custom.sh` in the same configuration
folder. Add custom commands there if you need to modify configuration or run
setup logic before SearXNG starts.

## Access

- Home Assistant sidebar/ingress: enabled
- Direct Web UI: `http://<your-ha-host>:8080`

## More Information

- [SearXNG Documentation](https://docs.searxng.org/)
- [SearXNG GitHub](https://github.com/searxng/searxng)
