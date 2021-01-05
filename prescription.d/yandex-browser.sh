#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=yandex-browser-beta

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Install Yandex browser from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yandex-browser-beta

# epm uses eget to download * names
epm install "https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/$(epm print constructname $PKGNAME "*" amd64 deb)"
