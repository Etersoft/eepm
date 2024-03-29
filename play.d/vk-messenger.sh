#!/bin/sh

PKGNAME=vk-messenger
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="VK Messenger from the official site"
URL="https://vk.me/app"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"
case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        pkgtype="deb"
        ;;
esac

PKGURL=$(epm tool eget --list --latest "$URL" "$PKGNAME.$pkgtype")

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm $repack install $PKGURL
