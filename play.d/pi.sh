#!/bin/sh

PKGNAME=pi
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="A terminal-based coding agent with multi-model support, mid-session model switching, and a simple CLI for headless coding tasks"
URL="https://github.com/badlogic/pi-mono"

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
    PKGURL=$(get_github_url "https://github.com/badlogic/pi-mono" "pi-linux-$ARCH.tar.gz")
else
    PKGURL="https://github.com/badlogic/pi-mono/releases/download/v$VERSION/pi-linux-$ARCH.tar.gz"
fi

install_pack_pkgurl
