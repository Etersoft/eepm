#!/bin/sh

PKGNAME=lidarr
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Lidarr music library manager"
URL="https://github.com/Lidarr/Lidarr"

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
    PKGURL=$(get_github_url "$URL" "*.linux-core-${arch}.tar.gz")
else
    PKGURL="$URL/releases/download/v${VERSION}/Lidarr.master.${VERSION}.linux-core-${arch}.tar.gz"
fi

install_pack_pkgurl
