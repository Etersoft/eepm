#!/bin/sh

PKGNAME=devin-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Devin Desktop — AI-powered code editor"
URL="https://devin.ai"

. $(dirname $0)/common.sh

# Upstream renamed Windsurf to Devin Desktop in v3.0.12:
# https://docs.devin.ai/desktop/changelog
RELEASES_URL="https://docs.devin.ai/desktop/changelog"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(fetch_url "$RELEASES_URL" | grep -oP 'https://windsurf-stable\.codeiumdata\.com/linux-x64-deb/stable/[^"]+/Devin-linux-x64-[^"]+\.deb' | head -1)
else
    PKGURL=$(fetch_url "$RELEASES_URL" | grep -oP "https://windsurf-stable\.codeiumdata\.com/linux-x64-deb/stable/[^/]+/Devin-linux-x64-$VERSION\.deb" | head -1)
fi

install_pkgurl
