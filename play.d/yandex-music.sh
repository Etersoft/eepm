#!/bin/sh

PKGNAME=yandex-music
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Native Yandex Music client for Linux. Made with OSX/Windows beta client repacking"
URL="https://github.com/cucumber-sp/yandex-music-linux/releases"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=amd64
        ;;
    aarch64)
        arch=arm64
        ;;
    armhf)
        arch=armhf
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/cucumber-sp/yandex-music-linux/" "yandex-music_.${VERSION}_${arch}.deb")
else
    PKGURL="https://github.com/cucumber-sp/yandex-music-linux/releases/download/v$VERSION/yandex-music_${VERSION}_${arch}.deb"
fi

install_pkgurl
