#!/bin/sh

PKGNAME=vk
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="VK Messenger from the official site"
URL="https://vk.com/vkme"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86)
        arch="i686"
        ;;
esac

PKGURL="$(eget --list --latest https://desktop.userapi.com/rpm/master/ "$PKGNAME-$VERSION.$arch.rpm")"

install_pkgurl
