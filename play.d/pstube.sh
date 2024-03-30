#!/bin/sh

PKGNAME=pstube-linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
# is not supported
DESCRIPTION='' #"PsTube (formerly FluTube) - Watch and download videos without ads. From the official site"
URL="https://github.com/prateekmedia/pstube"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        pkgtype="deb"
        ;;
esac

[ "$VERSION" = "*" ] && VERSION="[0-9]*"

arch=x86_64
# https://github.com/prateekmedia/pstube/releases/download/2.6.0/pstube-linux-2.6.0-x86_64.rpm
# https://github.com/prateekmedia/pstube/releases/download/2.6.0/pstube-linux-2.6.0-x86_64.deb
PKGURL=$(eget --list --latest https://github.com/prateekmedia/pstube/releases "$PKGNAME-$VERSION-$arch.$pkgtype") || fatal "Can't get package URL"

# we have workaround for their postinstall script, so always repack rpm package
[ "$pkgtype" = "deb" ] || repack='--repack'

epm install $repack "$PKGURL" || exit

