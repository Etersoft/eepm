#!/bin/sh

PKGNAME=kimi-code
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Kimi Code CLI - AI coding agent from Moonshot AI"
URL="https://github.com/MoonshotAI/kimi-code"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        arch=x64
        ;;
    aarch64)
        arch=arm64
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    # release tag is scoped: @moonshot-ai/kimi-code@VERSION
    VERSION="$(get_github_tag "$URL" | sed -e 's|.*@||')"
fi

PKGURL="$URL/releases/download/%40moonshot-ai%2Fkimi-code%40$VERSION/kimi-code-linux-$arch.zip"

install_pack_pkgurl
