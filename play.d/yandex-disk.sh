#!/bin/sh

PKGNAME=yandex-disk
DESCRIPTION="Yandex Disk from the official site"

. $(dirname $0)/common.sh


# http://repo.yandex.ru/yandex-disk/yandex-disk_latest_amd64.deb
# http://repo.yandex.ru/yandex-disk/yandex-disk-latest.x86_64.rpm
# http://repo.yandex.ru/yandex-disk/yandex-disk_latest_i386.deb
# http://repo.yandex.ru/yandex-disk/yandex-disk-latest.i386.rpm
# epm uses eget to download * names
epm install "http://repo.yandex.ru/yandex-disk/$(epm print constructname $PKGNAME "latest")"
