#!/bin/sh

PKGNAME=yandex-music
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Native Yandex Music client for Linux. Made with OSX/Windows beta client repacking"
URL="https://github.com/cucumber-sp/yandex-music-linux/releases"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"
case "$arch" in
    armv7l)
        arch=armhf
        ;;
esac

PKGURL=$(eget --list --latest https://github.com/cucumber-sp/yandex-music-linux/releases "yandex-music_${VERSION}_${arch}.deb")

install_pkgurl
