#!/bin/sh

PKGNAME=mimo-code
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="MiMo Code: AI coding agent for the terminal by Xiaomi"
URL="https://github.com/XiaomiMiMo/MiMo-Code"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag "$URL")
fi

arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        arch="x64"
        ;;
    aarch64)
        arch="arm64"
        ;;
esac

PKGURL="$URL/releases/download/v$VERSION/mimocode-linux-$arch.tar.gz"

install_pack_pkgurl
