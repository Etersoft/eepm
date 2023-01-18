#!/bin/sh

PKGNAME=vk
SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION="VK Messenger from the official site"

. $(dirname $0)/common.sh

arch="$($DISTRVENDOR -a)"
case "$arch" in
    x86)
        arch="i686"
        ;;
esac

URL=$(eget --list --latest https://desktop.userapi.com/rpm/master/ "*.$arch.rpm")

epm --repack install $URL
