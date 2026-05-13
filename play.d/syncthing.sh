#!/bin/sh

PKGNAME=syncthing
SUPPORTEDARCHES="x86_64 aarch64 i686"
VERSION="$2"
DESCRIPTION="Continuous file synchronization between devices"
URL="https://syncthing.net/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    i686)    ARCH="386" ;;
    *) fatal "Unsupported arch $arch" ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "syncthing/syncthing" "syncthing-linux-$ARCH-v*.tar.gz")
else
    PKGURL="https://github.com/syncthing/syncthing/releases/download/v$VERSION/syncthing-linux-$ARCH-v$VERSION.tar.gz"
fi

install_pack_pkgurl
