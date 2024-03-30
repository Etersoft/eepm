#!/bin/sh

PKGNAME=bitrix24
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Bitrix24 desktop client from the official site"
URL="https://www.bitrix24.ru/features/desktop.php"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://dl.bitrix24.com/b24/bitrix24_desktop.rpm"
        ;;
    deb)
        PKGURL="https://dl.bitrix24.com/b24/bitrix24_desktop.deb"
        ;;
esac

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL"
