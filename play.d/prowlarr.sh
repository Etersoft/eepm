#!/bin/sh

PKGNAME=prowlarr
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Prowlarr indexer manager for Sonarr/Radarr/Lidarr"
URL="https://github.com/Prowlarr/Prowlarr"

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
    PKGURL="$URL/releases/download/v${VERSION}/Prowlarr.master.${VERSION}.linux-core-${arch}.tar.gz"
fi

install_pack_pkgurl
