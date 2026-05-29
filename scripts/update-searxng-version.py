#!/usr/bin/env python3
"""Update the SearXNG add-on to a pinned upstream Docker tag."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "searxng" / "config.yaml"
DOCKERFILE = ROOT / "searxng" / "Dockerfile"
CHANGELOG = ROOT / "searxng" / "CHANGELOG.md"
DOCKER_HUB_TAGS = (
    "https://hub.docker.com/v2/repositories/searxng/searxng/"
    "tags?page_size=100&ordering=last_updated"
)
VERSION_RE = re.compile(r"^\d{4}\.\d{1,2}\.\d{1,2}-[0-9a-f]+$")


def output(name: str, value: str) -> None:
    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a", encoding="utf-8") as handle:
            handle.write(f"{name}={value}\n")
    print(f"{name}={value}")


def latest_upstream_version() -> str:
    with urllib.request.urlopen(DOCKER_HUB_TAGS, timeout=30) as response:
        payload = json.load(response)

    for item in payload.get("results", []):
        tag = item.get("name", "")
        if VERSION_RE.match(tag):
            return tag

    raise RuntimeError("No concrete SearXNG version tag found on Docker Hub")


def current_version() -> str:
    match = re.search(
        r"^version:[^\S\r\n]*(\S+)[^\S\r\n]*$",
        CONFIG.read_text(encoding="utf-8"),
        re.MULTILINE,
    )
    if not match:
        raise RuntimeError(f"Could not find version in {CONFIG}")
    return match.group(1)


def replace_once(path: Path, pattern: str, replacement: str) -> None:
    text = path.read_text(encoding="utf-8")
    next_text, count = re.subn(pattern, replacement, text, count=1, flags=re.MULTILINE)
    if count != 1:
        raise RuntimeError(f"Expected exactly one replacement in {path}")
    path.write_text(next_text, encoding="utf-8")


def update_changelog(version: str) -> None:
    today = datetime.now(timezone.utc).date().isoformat()
    text = CHANGELOG.read_text(encoding="utf-8")
    entry = (
        f"## {version} - {today}\n\n"
        f"- Bump upstream SearXNG image to `searxng/searxng:{version}`\n\n"
    )
    marker = "# Changelog\n\n"
    if not text.startswith(marker):
        raise RuntimeError(f"Unexpected changelog format in {CHANGELOG}")
    CHANGELOG.write_text(marker + entry + text[len(marker) :], encoding="utf-8")


def update_version(version: str) -> bool:
    current = current_version()
    output("previous_version", current)
    output("version", version)

    if current == version:
        output("changed", "false")
        return False

    replace_once(CONFIG, r"^version:[^\S\r\n]*\S+[^\S\r\n]*$", f"version: {version}")
    replace_once(
        DOCKERFILE,
        r"^ARG SEARXNG_IMAGE=searxng/searxng:\S+[^\S\r\n]*$",
        f"ARG SEARXNG_IMAGE=searxng/searxng:{version}",
    )
    update_changelog(version)
    output("changed", "true")
    return True


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--version",
        help="Specific searxng/searxng tag to pin. Defaults to newest Docker Hub version tag.",
    )
    args = parser.parse_args()

    version = args.version or latest_upstream_version()
    if not VERSION_RE.match(version):
        print(f"Invalid SearXNG version tag: {version}", file=sys.stderr)
        return 2

    update_version(version)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
