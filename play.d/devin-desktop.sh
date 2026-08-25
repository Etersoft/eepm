#!/bin/sh

PKGNAME=devin-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Devin Desktop — AI-powered code editor"
URL="https://devin.ai"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Upstream renamed Windsurf to Devin Desktop in v3.0.12:
# https://docs.devin.ai/desktop/changelog
API_URL="https://windsurf-stable.codeium.com/api/update/linux-x64-deb/stable/latest"

info="$(fetch_url "$API_URL")" || fatal "Can't get latest package info from $API_URL"

PKGURL="$(echo "$info" | parse_json_value url)"
[ -n "$PKGURL" ] || fatal "Can't get package URL from $API_URL"

install_pkgurl
