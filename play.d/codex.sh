#!/bin/sh

BASEPKGNAME=codex
SUPPORTEDARCHES="x86_64 aarch64"
PRODUCTALT="'' preview"
VERSION="$2"
DESCRIPTION="Codex CLI is a coding agent from OpenAI that runs locally on your computer."
URL="https://github.com/openai/codex"

. $(dirname $0)/common.sh

is_openssl_enough 3 || fatal "There is no needed OpenSSL 3 in the system."

arch="$(epm print info -a)"
arch="$arch-unknown-linux-gnu"

if [ "$PKGNAME" = "$BASEPKGNAME-preview" ] ; then
    prerelease="prerelease"
fi

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "codex-$arch.tar.gz" $prerelease)
else
    tag="rust-v$VERSION"
    PKGURL="https://github.com/openai/codex/releases/download/$tag/codex-$arch.tar.gz"
fi

install_pack_pkgurl
