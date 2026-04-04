#!/bin/sh

PKGNAME=GameCenterShowcase
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="VK Play — российская площадка для любителей игр, разработчиков и авторов контента"
URL="https://vkplay.ru/about/?from=gamecenter"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"

case $pkgtype in
    rpm)
        PKGURL="https://static.gc.vkplay.ru/gclinux/rpm_repo/GameCenterShowcase.x86_64.rpm"
        ;;
    *)
        PKGURL="https://static.gc.vkplay.ru/gclinux/deb_repo/GameCenterShowcase_amd64.deb"
        ;;
esac

install_pkgurl
