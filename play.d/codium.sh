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


PKGURL=$(eget --list --latest https://github.com/VSCodium/vscodium/releases $(epm print constructname $PKGNAME "$VERSION*" $arch $pkgtype)) || fatal "Can't get package URL"

# we have workaround for their postinstall script, so always repack rpm package
[ "$pkgtype" = "deb" ] || repack='--repack'

epm install $repack "$PKGURL" || exit

