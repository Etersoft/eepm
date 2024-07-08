#!/bin/sh

PKGNAME=pstube
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="PsTube (formerly FluTube) - Watch and download videos without ads. From the official site"
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

if ! is_glibc_enough 2.34 ; then
    fatal "glibc is too old"
fi

arch=x86_64
# https://github.com/prateekmedia/pstube/releases/download/2.6.0/pstube-linux-2.6.0-x86_64.rpm
# https://github.com/prateekmedia/pstube/releases/download/2.6.0/pstube-linux-2.6.0-x86_64.deb
# https://github.com/prateekmedia/pstube/releases/download/3.0.0-beta/pstube-3.0.0-beta-linux-x86_64.rpm
PKGURL=$(get_github_version "https://github.com/prateekmedia/pstube/" "$PKGNAME-.$VERSION-$arch.$pkgtype")

install_pkgurl
