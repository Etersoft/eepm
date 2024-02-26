#!/bin/sh

PKGNAME=YandexMusic
SUPPORTEDARCHES="x86_64 aarch64"
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
    *)
        fatal "$arch arch is not supported"
        ;;
esac

PKGURL=$(epm tool eget --list --latest https://github.com/cucumber-sp/yandex-music-linux/releases "yandex-music_${VERSION}_${arch}.deb")

epm install --repack $PKGURL
