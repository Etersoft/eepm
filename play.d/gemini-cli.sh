#!/bin/sh

PKGNAME=gemini-cli
SUPPORTEDARCHES="x86_64 aarch64" # any
VERSION="$2"
DESCRIPTION="An open-source AI agent that brings the power of Gemini directly into your terminal"
URL="https://github.com/google-gemini/gemini-cli"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] || [ "$VERSION" = "0" ] ; then
    VERSION=$(get_github_tag "$URL")
fi

PKGURL="https://registry.npmjs.org/@google/gemini-cli/-/gemini-cli-${VERSION}.tgz"

install_pack_pkgurl
