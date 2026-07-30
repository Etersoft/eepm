#!/bin/sh

PKGNAME=beekeeper-studio
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Beekeeper Studio - SQL editor and database manager"
URL="https://github.com/beekeeper-studio/beekeeper-studio"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        ARCH="x86_64"
        DEBARCH="amd64"
        ;;
    aarch64)
        ARCH="aarch64"
        DEBARCH="arm64"
        ;;
esac

case $(epm print info -p) in
    rpm)
        mask="${PKGNAME}-${VERSION}.$ARCH.rpm"
        ;;
    *)
        mask="${PKGNAME}_${VERSION}_$DEBARCH.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "$mask")"
else
    PKGURL="$URL/releases/download/v$VERSION/$mask"
fi

install_pkgurl
