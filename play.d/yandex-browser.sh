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

if epm installed yandex-browser-stable && [ "$(get_pkgvendor yandex-browser-stable)" = "YANDEX LLC" ] ; then
    if [ "$(epm print field Vendor for package yandex-browser-stable)" = "Yandex Browser Team <browser@support.yandex.ru>" ] ; then
        fatal "Package yandex-browser-stable is already manually from https://browser.yandex.ru/."
    else
        fatal "Package yandex-browser-stable is already installed from ALT repository."
    fi
fi


# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yandex-browser-beta

URL="https://repo.yandex.ru/yandex-browser"
update_url_if_need_mirrored || update_url_if_need_mirrored https://download.etersoft.ru/pub/download/yandex-browser

# epm uses eget to download * names
epm install "$URL/deb/pool/main/y/$PKGNAME/$(epm print constructname $PKGNAME "*" amd64 deb)" || exit

epm play yandex-browser-codecs-ffmpeg-extra $BRANCH
