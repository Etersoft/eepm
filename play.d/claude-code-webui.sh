#!/bin/sh

PKGNAME=claude-code-webui
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Web interface for Claude Code CLI"
URL="https://github.com/sugyan/claude-code-webui"

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

ASSET_NAME="$PKGNAME-linux-$arch"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "sugyan/claude-code-webui" "$ASSET_NAME")
    checksum=$(get_github_asset_checksum "sugyan/claude-code-webui" "$ASSET_NAME")
else
    PKGURL="https://github.com/sugyan/claude-code-webui/releases/download/$VERSION/$ASSET_NAME"
fi

install_pack_pkgurl "" "" "$checksum"
