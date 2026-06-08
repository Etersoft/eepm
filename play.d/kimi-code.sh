#!/bin/sh

PKGNAME=kimi-code
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="The Starting Point for Next-Gen Agents"
URL="https://github.com/MoonshotAI/kimi-code"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"

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

PKGURL=$(get_github_url "https://github.com/MoonshotAI/kimi-code" "kimi-code-linux-$arch.zip")

install_pack_pkgurl
