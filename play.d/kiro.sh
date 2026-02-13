#!/bin/sh

PKGNAME=kiro
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="An agentic AI IDE with spec-driven development from prototype to production"
URL="https://kiro.dev/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_json_value "https://prod.download.desktop.kiro.dev/stable/metadata-linux-x64-stable.json" "currentRelease")"
fi

PKGURL="https://prod.download.desktop.kiro.dev/releases/stable/linux-x64/signed/$VERSION/deb/kiro-ide-$VERSION-stable-linux-x64.deb"

install_pkgurl
