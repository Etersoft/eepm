#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=yandex-disk

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Install Yandex Disk from the official site" && exit

# http://repo.yandex.ru/yandex-disk/yandex-disk_latest_amd64.deb
# http://repo.yandex.ru/yandex-disk/yandex-disk-latest.x86_64.rpm
# http://repo.yandex.ru/yandex-disk/yandex-disk_latest_i386.deb
# http://repo.yandex.ru/yandex-disk/yandex-disk-latest.i386.rpm
# epm uses eget to download * names
epm install "http://repo.yandex.ru/yandex-disk/$(epm print constructname $PKGNAME "latest")"
