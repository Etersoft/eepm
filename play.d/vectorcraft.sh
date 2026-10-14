#!/bin/sh

PKGNAME=vectorcraft
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Vector graphics editor'
URL="https://github.com/storytold/vectorcraft"

. $(dirname $0)/common.sh

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
    PKGURL=$(get_github_url "$URL" "$PKGNAME-*-linux-$arch.$pkgtype")
else
    PKGURL="$URL/releases/download/v$VERSION/$PKGNAME-$VERSION-linux-$arch.$pkgtype"
fi

install_pkgurl
