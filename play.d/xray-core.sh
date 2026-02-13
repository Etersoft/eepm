#!/bin/sh

PKGNAME=xray-core
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Xray-core - a platform for building proxies to bypass network restrictions (VLESS, VMess, Trojan, Shadowsocks)"
URL="https://github.com/XTLS/Xray-core"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        file="Xray-linux-64.zip"
        ;;
    aarch64)
        file="Xray-linux-arm64-v8a.zip"
        ;;
    armhf)
        file="Xray-linux-arm32-v7a.zip"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag https://github.com/XTLS/Xray-core/)"
fi

PKGURL="https://github.com/XTLS/Xray-core/releases/download/v$VERSION/$file"

install_pack_pkgurl $VERSION
