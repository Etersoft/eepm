#!/bin/sh

PKGNAME=sonarr
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Sonarr TV series manager"
URL="https://github.com/Sonarr/Sonarr"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch="x64" ;;
    aarch64)
        arch="arm64" ;;
    armhf)
        arch="arm" ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "*.linux-${arch}.tar.gz")
else
    PKGURL="$URL/releases/download/v${VERSION}/Sonarr.main.${VERSION}.linux-${arch}.tar.gz"
fi

install_pack_pkgurl
