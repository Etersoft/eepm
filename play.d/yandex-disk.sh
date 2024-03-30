#!/bin/sh

PKGNAME=yandex-disk
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="Yandex Disk from the official site"
URL="https://360.yandex.com/disk/download/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# https://repo.yandex.ru/yandex-disk/yandex-disk_latest_amd64.deb
# https://repo.yandex.ru/yandex-disk/yandex-disk-latest.x86_64.rpm
# https://repo.yandex.ru/yandex-disk/yandex-disk_latest_i386.deb
# https://repo.yandex.ru/yandex-disk/yandex-disk-latest.i386.rpm
# epm uses eget to download * names

PKGURL="https://repo.yandex.ru/yandex-disk/$(epm print constructname $PKGNAME "latest")" || fatal "Can't get package URL"
epm install "$PKGURL" || exit

# Install also tray indicator
if [ "$(epm print info -s)" = "alt" ] ; then
    epm install --skip-installed yandex-disk-indicator
fi

true
