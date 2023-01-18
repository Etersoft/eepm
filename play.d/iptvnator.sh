#!/bin/sh

PKGNAME=iptvnator
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION='IPTV player from the official site'

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

PKG=$(epm tool eget --list --latest https://github.com/4gray/iptvnator/releases/ "$PKGNAME*$arch.$pkgtype") || fatal "Can't get package URL"
[ -n "$PKG" ] || fatal "Can't get package URL"

epm install "$PKG"
