#!/bin/sh

PKGNAME=abacusai
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="AbacusAI's powerful CLI AI assistant with agentic browsing, listening, and coding capabilities"
URL="https://github.com/abacusai/deepagent-releases"

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
    PKGURL=$(get_github_url "$URL" "abacusai-agent-cli-linux-$ARCH-$VERSION.tar.gz")
else
    PKGURL="https://github.com/abacusai/deepagent-releases/releases/download/$VERSION/abacusai-agent-cli-linux-$ARCH-$VERSION.tar.gz"
fi

install_pack_pkgurl
