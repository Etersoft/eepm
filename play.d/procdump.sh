#!/bin/sh

PKGNAME=procdump
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="ProcDump - Sysinternals process dump utility for Linux"
URL="https://github.com/microsoft/ProcDump-Linux"

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
        mask="$PKGNAME-$VERSION-0.el8.$ARCH.rpm"
        ;;
    *)
        mask="${PKGNAME}_${VERSION}_$DEBARCH.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "$mask")"
else
    PKGURL="$URL/releases/download/$VERSION/$mask"
fi

install_pkgurl
