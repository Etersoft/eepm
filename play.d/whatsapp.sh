#!/bin/sh

PKGNAME=whatsapp-for-linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='An unofficial WhatsApp desktop application (from the repository if the package is there, or from the official site)'
URL="https://github.com/eneshecan/whatsapp-for-linux"

. $(dirname $0)/common.sh

if epm install $PKGNAME ; then
    exit 0
fi

[ "$(epm print info -s)" = "alt" ] && fatal "ALT is not supports $PKGNAME AppImage for now."

arch=x86_64
# sh: symbol lookup error: /tmp/.private/lav/.mount_whatsaxhRMDh/opt/libc/lib/x86_64-linux-gnu/libc.so.6: undefined symbol: __libc_enable_secure, version GLIBC_PRIVATE
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/eneshecan/whatsapp-for-linux/" "$PKGNAME-.$VERSION-$arch.AppImage")
else
    PKGURL="https://github.com/eneshecan/whatsapp-for-linux/releases/download/v$VERSION/$PKGNAME-$VERSION-$arch.AppImage"
fi

install_pkgurl
