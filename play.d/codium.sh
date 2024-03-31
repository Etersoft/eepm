#!/bin/sh

PKGNAME=codium
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Codium from the official site"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
pkgtype="$(epm print info -p)"
case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        pkgtype="deb"
        ;;
esac

case "$arch-$pkgtype" in
    x86_64-deb)
        arch=amd64
        ;;
    armhf-rpm)
        arch=armv7hl
        ;;
    aarch64)
        arch=arm64
        ;;
esac


mask="$(epm print constructname $PKGNAME "$VERSION*" $arch $pkgtype)"
PKGURL="$(eget --list --latest https://github.com/VSCodium/vscodium/releases "$mask")" || fatal "Can't get package URL"

install_pkgurl

