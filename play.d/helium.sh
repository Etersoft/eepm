#!/bin/sh

PKGNAME=helium
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Private, fast, and honest web browser based on Chromium"
URL="https://github.com/imputnet/helium-linux"

. $(dirname $0)/common.sh

arch="$(epm print info --distro-arch)"
[ "$arch" = "aarch64" ] && arch="arm64"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL/" "$PKGNAME-${VERSION}-${arch}_linux.tar.xz")
else
    PKGURL="$URL/releases/download/${VERSION}/$PKGNAME-${VERSION}-${arch}_linux.tar.xz"
fi

install_pack_pkgurl
