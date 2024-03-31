#!/bin/sh

PKGNAME=iptvnator
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='IPTV player from the official site'
URL="https://github.com/4gray/iptvnator"

. $(dirname $0)/common.sh

arch=$(epm print info -a)
case "$arch" in
    x86_64)
        arch=amd64
        ;;
    aarch64)
        arch=arm64
        ;;
esac

pkgtype=deb

PKGURL=$(eget --list --latest https://github.com/4gray/iptvnator/releases/ "$PKGNAME*$VERSION*$arch.$pkgtype")

install_pkgurl
