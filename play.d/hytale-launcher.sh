#!/bin/sh

PKGNAME=hytale-launcher
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Hytale Launcher (Native Linux, Self-Updating)"
URL="https://hytale.com"

. $(dirname $0)/common.sh

warn_version_is_not_supported

LAUNCHER_JSON="https://launcher.hytale.com/version/release/launcher.json"
JSON="$(eget -O- "$LAUNCHER_JSON")"

VERSION="$(echo "$JSON" | parse_json_value '["version"]' | tr '-' '.')"
[ -n "$VERSION" ] || fatal "Can't get version from $LAUNCHER_JSON"

PKGURL="$(echo "$JSON" | parse_json_value '["download_url","linux","amd64","url"]')"
[ -n "$PKGURL" ] || fatal "Can't get download URL from $LAUNCHER_JSON"

install_pack_pkgurl $VERSION
