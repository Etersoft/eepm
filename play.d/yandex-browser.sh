#!/bin/sh

BASEPKGNAME=yandex-browser
SUPPORTEDARCHES="x86_64"
PRODUCTALT="stable beta"
VERSION="$2"
DESCRIPTION="Yandex browser from the official site"
URL="https://browser.yandex.ru/"
TIPS="Run 'epm play yandex-browser=beta' to install beta version of the browser."

. $(dirname $0)/common.sh

warn_version_is_not_supported

URL="https://browser.yandex.ru/download"

if [ "$BRANCH" = "beta" ]; then
    BETA_FLAG="&beta=1"
else
    BETA_FLAG=""
fi

if [ "$(epm print info -p)" = "rpm" ] ; then
    [ "$BRANCH" = "corporate" ] && BRANCH="stable"
    PKGURL="$URL?os=linux&package=rpm${BETA_FLAG}"
else
    PKGURL="$URL?os=linux&package=deb${BETA_FLAG}"
fi

install_pkgurl

epm play $PKGNAME-codecs-ffmpeg-extra
