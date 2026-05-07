#!/bin/sh

PKGNAME=kimi-cli
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Kimi CLI - AI coding agent from Moonshot AI"
URL="https://github.com/MoonshotAI/kimi-cli"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "kimi-*-$arch-unknown-linux-gnu.tar.gz")
else
    PKGURL="https://github.com/MoonshotAI/kimi-cli/releases/download/$VERSION/kimi-$VERSION-$arch-unknown-linux-gnu.tar.gz"
fi

install_pack_pkgurl
