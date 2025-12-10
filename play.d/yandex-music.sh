#!/bin/sh

PKGNAME=yandexmusic
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Native Yandex Music client for Linux"
URL="https://music.yandex.ru/download"

. $(dirname $0)/common.sh

DOWNLOAD_JSON="https://music-desktop-application.s3.yandex.net/stable/download.json"

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget -O- "$DOWNLOAD_JSON" | epm tool json -b | get_json_value "linux")"
else
    PKGURL="https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_amd64_${VERSION}.deb"
fi

install_pkgurl
