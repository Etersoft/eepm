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

PKGURL=$(eget --list --latest https://github.com/cucumber-sp/yandex-music-linux/releases "yandex-music_${VERSION}_${arch}.deb") || fatal "Can't get package URL"

install_pkgurl
