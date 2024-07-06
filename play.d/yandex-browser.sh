#!/bin/sh

BASEPKGNAME=yandex-browser
SUPPORTEDARCHES="x86_64"
PRODUCTALT="stable beta corporate"
VERSION="$2"
DESCRIPTION="Yandex browser from the official site"
URL="https://browser.yandex.ru/"
TIPS="Run 'epm play yandex-browser=beta' to install beta version of the browser."

. $(dirname $0)/common.sh

warn_version_is_not_supported
VERSION="*"

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yandex-browser-beta

URL="https://repo.yandex.ru/yandex-browser"

if [ "$(epm print info -p)" = "rpm" ] ; then
    # https://repo.yandex.ru/yandex-browser/rpm/stable/x86_64/yandex-browser-stable-23.1.1.1114-1.x86_64.rpm
    [ "$BRANCH" = "corporate" ] && BRANCH="stable"
    PKGURL="$URL/rpm/$BRANCH/x86_64/$(epm print constructname $PKGNAME "$VERSION*" x86_64 rpm)"
else
    # https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/yandex-browser-beta_23.5.4.682-1_amd64.deb
    PKGURL="$URL/deb/pool/main/y/$PKGNAME/$(epm print constructname $PKGNAME "$VERSION*" amd64 deb)"
fi

if [ "$(epm print info -s)" = "redos" ] ; then
    BRANCH="stable"
    PKGURL="$URL/rpm/redos/x86_64/$(epm print constructname $PKGNAME "$VERSION*" x86_64 rpm)"
fi

install_pkgurl

# TODO: use needed version
if [ "$(epm print info -s)" = "alt" ] ; then
    epm install ffmpeg-plugin-browser
    exit
else
    epm play nwjs-ffmpeg-prebuilt=0.87.0
    exit
fi

