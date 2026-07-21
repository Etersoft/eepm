#!/bin/sh

PKGNAME=Lolka
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Lolka — платформа для общения в реальном времени (аналог Discord)'
URL="https://lolka.app"

. $(dirname $0)/common.sh

warn_version_is_not_supported

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- https://storage.yandexcloud.net/lolka-electron/releases/latest-linux.yml | awk -F': ' '/^version:/{print $2; exit}' | tr -d '\r')
fi

if [ "$(epm print info -p)" = "rpm" ] ; then
    PKGURL="https://storage.yandexcloud.net/lolka-electron/releases/Lolka-$VERSION.x86_64.rpm"
else
    PKGURL="https://storage.yandexcloud.net/lolka-electron/releases/Lolka_${VERSION}_amd64.deb"
fi

install_pkgurl
