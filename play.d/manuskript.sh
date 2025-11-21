#!/bin/sh

PKGNAME=manuskript
SUPPORTEDARCHES=""
VERSION="$2"
DESCRIPTION="A open-source tool for writers for Linux from the official site"
URL="http://www.theologeek.ch/manuskript"

. $(dirname $0)/common.sh

case $(epm print info -p) in
    rpm)
        file="$PKGNAME-$VERSION-1.noarch.rpm"
        ;;
    *)
        file="$PKGNAME-$VERSION-1.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "https://github.com/olivierkes/manuskript" "$file")"
else
    PKGURL="https://github.com/olivierkes/manuskript/releases/download/$version/$file"
fi

install_pkgurl

