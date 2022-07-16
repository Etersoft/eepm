#!/bin/sh

PRODUCTDIR=/opt/yandex/browser
DESCRIPTION="Yandex browser from the official site"
TIPS="Run 'epm play yandex-browser beta' to install beta version of the browser."

PRODUCTALT="stable beta"
BRANCH=stable
if [ "$2" = "beta" ] || epm installed yandex-browser-beta ; then
    BRANCH=beta
    PRODUCTDIR=/opt/yandex/browser-$BRANCH
fi

PKGNAME=yandex-browser-$BRANCH
SUPPORTEDARCHES="x86_64"

. $(dirname $0)/common.sh

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yandex-browser-beta

# epm uses eget to download * names
epm install "https://repo.yandex.ru/yandex-browser/deb/pool/main/y/$PKGNAME/$(epm print constructname $PKGNAME "*" amd64 deb)" || exit

epm play yandex-browser-codecs-ffmpeg-extra $BRANCH
