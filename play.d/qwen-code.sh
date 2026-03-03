#!/bin/sh

PKGNAME=qwen-code
SUPPORTEDARCHES="x86_64 aarch64" # any
VERSION="$2"
DESCRIPTION="Open-source AI agent based on Gemini CLI by QwenLM"
URL="https://github.com/QwenLM/qwen-code"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url $URL "cli.js")

install_pack_pkgurl
