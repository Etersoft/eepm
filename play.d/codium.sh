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

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/VSCodium/vscodium/" "$(epm print constructname $PKGNAME ".$VERSION*" $arch $pkgtype)")
else
    PKGURL=$(get_github_version "https://github.com/VSCodium/vscodium/" "$(epm print constructname $PKGNAME "$VERSION*" $arch $pkgtype)")
fi

install_pkgurl

