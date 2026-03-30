#!/bin/sh

PKGNAME=telemt
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Telemt MTProxy - high-performance Telegram proxy server written in Rust"
URL="https://github.com/telemt/telemt"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag "$URL")
fi

PKGURL="https://github.com/telemt/telemt/releases/download/$VERSION/$PKGNAME-x86_64-linux-musl.tar.gz"

install_pack_pkgurl $VERSION
