#!/bin/sh

PKGNAME=faugus-launcher
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A simple and lightweight app for running Windows games"
URL="https://github.com/Faugus/faugus-launcher"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/Faugus/faugus-launcher" "${PKGNAME}-${VERSION}-*.noarch.rpm")
else
    PKGURL="$(eget --list --latest "https://github.com/Faugus/faugus-launcher/releases" "${PKGNAME}-${VERSION}-*.noarch.rpm")"
fi

install_pkgurl
