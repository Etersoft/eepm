#!/bin/sh

PKGNAME=codium
SUPPORTEDARCHES="x86_64 armhf"
DESCRIPTION="Codium from the official site"

. $(dirname $0)/common.sh

if epm installed $PKGNAME && [ "$(get_pkgvendor $PKGNAME)" = "ALT Linux Team" ]  ; then
    echo "Package $PKGNAME is already installed from ALT repository."
    exit 0
fi


VERSION="$2"

arch="$(epm print info -a)"
pkgtype="$(epm print info -p)"
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


PKG=$(epm tool eget --list --latest https://github.com/VSCodium/vscodium/releases "$PKGNAME-*$arch.$pkgtype") || fatal "Can't get package URL"

# we have workaround for their postinstall script, so always repack rpm package
[ "$pkgtype" = "deb" ] || repack='--repack'

epm install $repack "$PKG" || exit

