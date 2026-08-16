#!/bin/sh

PKGNAME=codexbar
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Usage and status CLI for OpenAI Codex and Claude Code"
URL="https://github.com/steipete/CodexBar"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag "$URL")
fi

arch="$(epm print info -a)"
PKGURL="$URL/releases/download/v$VERSION/CodexBarCLI-v$VERSION-linux-$arch.tar.gz"

install_pack_pkgurl
