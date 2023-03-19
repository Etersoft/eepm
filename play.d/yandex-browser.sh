#!/bin/sh

DESCRIPTION="Yandex browser from the official site"
TIPS="Run 'epm play yandex-browser beta' to install beta version of the browser."

PRODUCTALT="stable beta"
BRANCH=stable
if [ "$2" = "beta" ] || epm installed yandex-browser-beta ; then
    BRANCH=beta
fi

PKGNAME=yandex-browser-$BRANCH
SUPPORTEDARCHES="x86_64"

. $(dirname $0)/common.sh

if epm installed $PKGNAME && [ "$(get_pkgvendor $PKGNAME)" = "YANDEX LLC" ] ; then
    if [ "$(epm print field Vendor for package $PKGNAME)" = "Yandex Browser Team <browser@support.yandex.ru>" ] ; then
        echo "Package $PKGNAME is already installed manually from https://browser.yandex.ru/."
    else
        echo "Package $PKGNAME is already installed from ALT repository."
    fi
    exit 0
fi


# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yandex-browser-beta

URL="https://repo.yandex.ru/yandex-browser"
update_url_if_need_mirrored || update_url_if_need_mirrored https://download.etersoft.ru/pub/download/yandex-browser

if [ "$(epm print info -s)" = "alt" ] || [ "$(epm print info -p)" != "rpm" ] ; then
    # epm uses eget to download * names
    epm install "$URL/deb/pool/main/y/$PKGNAME/$(epm print constructname $PKGNAME "*" amd64 deb)" || exit
else
    # https://repo.yandex.ru/yandex-browser/rpm/stable/x86_64/yandex-browser-stable-23.1.1.1114-1.x86_64.rpm
    epm install "$URL/rpm/stable/x86_64/$(epm print constructname $PKGNAME "*" x86_64 rpm)" || exit
fi

epm play yandex-browser-codecs-ffmpeg-extra $BRANCH
