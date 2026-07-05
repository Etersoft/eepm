#!/bin/sh

PKGNAME=zcode-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='ZCode — official desktop harness for GLM-5.2 from z.ai'
URL="https://zcode.z.ai/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        ARCH="x64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
esac

# https://cdn-zcode.z.ai/zcode/electron/releases/3.2.5/ZCode-3.2.5-linux-x64.deb
PKG="ZCode-$VERSION-linux-$ARCH.deb"
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(eget --list --latest "https://zcode.z.ai/en" "ZCode-[0-9.]*-linux-$ARCH.deb")
else
    PKGURL="https://cdn-zcode.z.ai/zcode/electron/releases/$VERSION/$PKG"
fi

install_pkgurl
