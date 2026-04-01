#!/bin/sh

PKGNAME=qwen-code
SUPPORTEDARCHES="x86_64 aarch64" # any
VERSION="$2"
DESCRIPTION="Open-source AI agent based on Gemini CLI by QwenLM"
URL="https://github.com/QwenLM/qwen-code"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag https://github.com/QwenLM/qwen-code)
fi

PKGURL="https://registry.npmjs.org/@qwen-code/qwen-code/-/qwen-code-${VERSION}.tgz"

install_pack_pkgurl
