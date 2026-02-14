#!/bin/sh

PKGNAME=opencode
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="The AI coding agent built for the terminal."
URL="https://github.com/anomalyco/opencode"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        arch="x64"
        ;;
    aarch64)
        arch="arm64"
        ;;
esac

PKGURL=$(get_github_url "$URL" "opencode-linux-$arch.tar.gz")

install_pack_pkgurl
