#!/bin/sh

PKGNAME=far2l-portable
SUPPORTEDARCHES="x86_64 x86 aarch64"
DESCRIPTION="FAR2L Portable from the official site"

. $(dirname $0)/common.sh

arch=$(epm print info -a)
case $arch in
    x86_64)
        arch="amd64" ;;
    x86)
        arch="i386" ;;
    aarch64)
        arch=$arch ;;
    *)
        fatal "Unsupported arch $arch for $(epm print info -d)"
esac


PKGURL="https://github.com/unxed/far2l-deb/raw/master/portable/far2l_portable_$arch.tar.gz"
epm pack --install $PKGNAME "$PKGURL"
