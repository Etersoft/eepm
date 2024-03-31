#!/bin/sh

PKGNAME=vk-messenger
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="VK Messenger from the official site"
URL="https://vk.me/app"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"
case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        pkgtype="deb"
        ;;
esac

PKGURL="$(eget --list --latest "$URL" "$PKGNAME.$pkgtype")"

install_pkgurl
