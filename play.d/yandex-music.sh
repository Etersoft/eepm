#!/bin/sh

PKGNAME=yandexmusic
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Native Yandex Music client for Linux"
URL="https://music.yandex.ru/download"

. $(dirname $0)/common.sh


DOWNLOAD_JSON="https://music-desktop-application.s3.yandex.net/stable/download.json"
JSON="$(eget -O- "$DOWNLOAD_JSON")"

if [ "$VERSION" = "*" ] ; then
    VERSION=$(echo $JSON | grep -oP '(?<=Yandex_Music_amd64_)[0-9.]+(?=\.deb)')
fi

PKGURL="https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_amd64_${VERSION}.deb"

install_pack_pkgurl "$VERSION"
