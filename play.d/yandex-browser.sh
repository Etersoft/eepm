#!/bin/sh

BRANCH=stable
PKGNAME=yandex-browser-stable
PRODUCTDIR=/opt/yandex/browser
DESCRIPTION="Yandex browser from the official site"

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    epm remove $PKGNAME-codecs-ffmpeg-extra
    exit
fi

. $(dirname $0)/common.sh

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yandex-browser-beta

# epm uses eget to download * names
epm install "https://repo.yandex.ru/yandex-browser/deb/pool/main/y/$PKGNAME/$(epm print constructname $PKGNAME "*" amd64 deb)" || exit

epm play yandex-browser-codecs-ffmpeg-extra $BRANCH
