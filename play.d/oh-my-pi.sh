#!/bin/sh

PKGNAME=oh-my-pi
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Oh My Pi - terminal AI coding agent with built-in development tools"
URL="https://github.com/can1357/oh-my-pi"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        ARCH=x64
        ;;
    aarch64)
        ARCH=arm64
        ;;
esac

if [ "$VERSION" = "*" ]; then
    PKGURL=$(get_github_url "$URL" "omp-linux-$ARCH")
else
    PKGURL="$URL/releases/download/v$VERSION/omp-linux-$ARCH"
fi

install_pack_pkgurl
