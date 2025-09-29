#!/bin/sh

PKGNAME=codium
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Codium from the official site"
URL="https://github.com/VSCodium/vscodium/releases"

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

suff=""
[ "$pkgtype" = "rpm" ] && suff="-el8"

mask="$(epm print constructname $PKGNAME "$VERSION$suff" $arch $pkgtype)"

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://github.com/VSCodium/vscodium/releases "$mask")"
else
    PKGURL="https://github.com/VSCodium/vscodium/releases/download/$VERSION/$mask"
fi

install_pkgurl

