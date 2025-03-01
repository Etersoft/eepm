#!/bin/sh

PKGNAME=netbird-ui
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="GUI for managing NetBird's WireGuard® overlay network."
URL="https://github.com/netbirdio/netbird"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
if [ "$arch" != "x86_64" ]; then
    fatal "NetBird UI is only available for x86_64 architecture"
fi

if [ "$VERSION" = "*" ]; then
    VERSION="$(get_github_tag https://github.com/netbirdio/netbird/)"
fi

PKGURL="https://github.com/netbirdio/netbird/releases/download/v${VERSION}/netbird-ui_${VERSION}_linux_amd64.deb"

install_pkgurl
