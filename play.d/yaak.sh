#!/bin/sh

PKGNAME=yaak
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Yaak - local-first API client"
URL="https://github.com/mountain-loop/yaak"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        rpmarch=x86_64
        debarch=amd64
        ;;
    aarch64)
        rpmarch=aarch64
        debarch=arm64
        ;;
esac

case "$(epm print info -p)" in
    rpm)
        file="yaak-$VERSION-1.$rpmarch.rpm"
        ;;
    deb)
        file="yaak_${VERSION}_${debarch}.deb"
        ;;
    *)
        file="yaak_${VERSION}_${debarch}.AppImage"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "$file")"
else
    PKGURL="$URL/releases/download/v$VERSION/$file"
fi

install_pkgurl
