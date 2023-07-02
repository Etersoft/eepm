#!/bin/sh

PKGNAME=urserver

SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION="Unified Remote Server from the official site"
URL="https://www.unifiedremote.com/"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
arch="$(epm print info -a)"
case "$pkgtype-$arch" in
    rpm-x86_64)
        file="linux-x64-rpm"
        ;;
    rpm-x86)
        file="linux-x86-rpm"
        ;;
    *-x86)
        file="linux-x86-deb"
        ;;
    *-x86_64)
        file="linux-x64-deb"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

PKGURL="https://www.unifiedremote.com/download/$file"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL"
