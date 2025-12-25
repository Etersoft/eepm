#!/bin/sh

PKGNAME=yandex-browser-corporate
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Yandex Browser Corporate from the official site"
URL="https://browser.yandex.ru/corp/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

REPOURL="https://repo.yandex.ru/yandex-browser"

if [ "$(epm print info -p)" = "rpm" ] ; then
    # https://repo.yandex.ru/yandex-browser/rpm/stable/x86_64/yandex-browser-corporate-25.10.1.1210-1.x86_64.rpm
    PKGURL="$REPOURL/rpm/stable/x86_64/$(epm print constructname $PKGNAME "$VERSION*" x86_64 rpm)"
else
    # https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-corporate/
    PKGURL="$REPOURL/deb/pool/main/y/$PKGNAME/$(epm print constructname $PKGNAME "$VERSION*" amd64 deb)"
fi

install_pkgurl

epm play $PKGNAME-codecs-ffmpeg-extra
