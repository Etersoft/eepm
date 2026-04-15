#!/bin/sh

PKGNAME=kilo
SUPPORTEDARCHES="x86_64 aarch64"

# https://github.com/Kilo-Org/kilocode/issues/8760
VERSION="7.2.0"
DESCRIPTION="The all-in-one agentic engineering platform"
URL="https://github.com/Kilo-Org/kilocode"

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

if [ "$VERSION" = "*" ]; then
    PKGURL=$(get_github_url "$URL" "kilo-linux-$ARCH.tar.gz")
else
    PKGURL="https://github.com/Kilo-Org/kilocode/releases/download/v$VERSION/kilo-linux-$ARCH.tar.gz"
fi

install_pack_pkgurl
