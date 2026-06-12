#!/bin/sh

PKGNAME=mimo-code
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Next-generation AI coding assistant for developers with unlimited context"
URL="https://github.com/XiaomiMiMo/MiMo-Code"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x64
        ;;
    aarch64)
        arch=arm64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

PKGURL=$(get_github_url "$URL" "mimocode-linux-$arch.tar.gz")

install_pack_pkgurl
