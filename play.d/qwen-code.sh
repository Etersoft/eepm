#!/bin/sh

PKGNAME=qwen-code
SUPPORTEDARCHES="x86_64 aarch64" # any
VERSION="$2"
DESCRIPTION="Open-source AI agent based on Gemini CLI by QwenLM"
URL="https://github.com/QwenLM/qwen-code"

. $(dirname $0)/common.sh

# drop v0.10.2-nightly.20260217.a0a0a70b and v0.10.2-preview.0
PKGURL=$(get_github_release_info  $URL |  grep 'browser_download_url' | grep -iEo 'https.*download.*' | grep -vi nightly | grep -vi preview | grep -E "cli.js" | head -n1 | sed -e 's|"$||')

install_pack_pkgurl
