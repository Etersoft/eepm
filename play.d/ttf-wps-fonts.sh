#!/bin/sh

PKGNAME=ttf-wps-fonts
SUPPORTEDARCHES=""
DESCRIPTION="Symbol fonts required by wps-office"
URL="https://github.com/ferion11/ttf-wps-fonts"
VERSION="$2"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag "$URL")"
fi
PKGURL="$URL/archive/refs/tags/v${VERSION}.tar.gz"

install_pack_pkgurl $VERSION
