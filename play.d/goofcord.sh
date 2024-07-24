#!/bin/sh

PKGNAME=goofcord
SUPPORTEDARCHES="x86_64 arm64"
VERSION="$2"
DESCRIPTION="The highly configurable and privacy minded discord client"
URL="https://github.com/Milkshiift/GoofCord/"

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


pkgtype=deb

PKGURL=$(eget --list --latest https://github.com/Milkshiift/GoofCord/releases "GoofCord-$VERSION-linux-$arch.$pkgtype")

install_pkgurl
