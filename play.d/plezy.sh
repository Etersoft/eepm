#!/bin/sh

PKGNAME=plezy
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="A modern client for Plex and Jellyfin"
URL="https://github.com/edde746/plezy"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        ARCH="x64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
esac

case $(epm print info -p) in
    rpm)
        mask="plezy-linux-$ARCH.rpm"
        ;;
    *)
        mask="plezy-linux-$ARCH.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/edde746/plezy" "$mask")
else
    PKGURL="https://github.com/edde746/plezy/releases/download/${VERSION}/$mask"
fi

install_pkgurl
