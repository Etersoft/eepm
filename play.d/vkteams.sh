#!/bin/sh

PKGNAME=vkteams
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="VK Teams for Linux from the official site"
URL="https://workspace.vk.ru/download/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"
case "$pkgtype" in
    rpm)
        PKGURL="https://vkteams-www.hb.bizmrg.com/linux/x64/vkteams.rpm"
        ;;
    deb)
        PKGURL="https://vkteams-www.hb.bizmrg.com/linux/x64/vkteams.deb"
        ;;
    *)
        PKGURL="https://vkteams-www.hb.bizmrg.com/linux/x64/vkteams.deb"
        ;;
esac

install_pkgurl
