#!/bin/sh

PKGNAME=deckcraft
SUPPORTEDARCHES="x86_64 aarch64 riscv64"
VERSION="$2"
DESCRIPTION='Presentation and slide editor'
URL="https://github.com/storytold/deckcraft"

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
