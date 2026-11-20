#!/bin/sh

PKGNAME=art-craft
ASSETNAME=artcraft
SUPPORTEDARCHES="x86_64 aarch64 riscv64"
VERSION="$2"
DESCRIPTION='Creative tool for artists, designers, and filmmakers'
URL="https://github.com/storytold/artcraft"

. $(dirname "$0")/common.sh

arch="$(epm print info -a)"
case "$(epm print info -p)" in
    rpm)
        pkgtype=rpm
        ;;
    *)
        pkgtype=deb
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "$ASSETNAME-*-linux-$arch.$pkgtype")
else
    PKGURL="$URL/releases/download/artcraft-v$VERSION/$ASSETNAME-$VERSION-linux-$arch.$pkgtype"
fi

install_pkgurl
