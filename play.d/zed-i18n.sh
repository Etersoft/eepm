#!/bin/sh

PKGNAME=zed-i18n
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Community build of the Zed editor with a multilingual interface"
URL="https://github.com/LI-NA/zed-i18n"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x86_64
        ;;
    aarch64)
        arch=aarch64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "zed-i18n-linux-$arch.tar.gz")
else
    VERSION=$(printf '%s\n' "$VERSION" | sed 's/\.i18n\./-i18n./')
    [ -n "$3" ] && VERSION="$VERSION-$3"
    PKGURL="$URL/releases/download/v$VERSION/zed-i18n-linux-$arch.tar.gz"
fi

install_pack_pkgurl
