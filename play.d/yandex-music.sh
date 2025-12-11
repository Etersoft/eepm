#!/bin/sh

PKGNAME=yandexmusic
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Native Yandex Music client for Linux"
URL="https://music.yandex.ru/download"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_json_value "https://music-desktop-application.s3.yandex.net/stable/download.json" "linux")"
else
    PKGURL="https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_amd64_${VERSION}.deb"
fi

install_pkgurl
