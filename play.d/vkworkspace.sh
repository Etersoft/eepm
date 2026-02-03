#!/bin/sh

PKGNAME=vkworkspace
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="VK WorkSpace for Linux from the official site"
URL="https://workspace.vk.ru/download/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"
case "$pkgtype" in
    rpm)
        PKGURL="https://hb.bizmrg.com/vkteams-www/linux/x64/vkworkspace.rpm"
        ;;
    deb)
        PKGURL="https://hb.bizmrg.com/vkteams-www/linux/x64/vkworkspace.deb"
        ;;
    *)
        PKGURL="https://hb.bizmrg.com/vkteams-www/linux/x64/vkworkspace.deb"
        ;;
esac

install_pkgurl
