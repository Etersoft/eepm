#!/bin/sh

PKGNAME=qwen-code
SUPPORTEDARCHES="x86_64 aarch64" # any
VERSION="$2"
DESCRIPTION="Open-source AI agent based on Gemini CLI by QwenLM"
URL="https://github.com/QwenLM/qwen-code"

. $(dirname $0)/common.sh

# drop nightly/preview: some are not marked prerelease on GitHub (their bug)
PKGURL=$(get_github_release_info $URL | __get_github_download_urls | grep -vi nightly | grep -vi preview | grep -E "cli.js" | head -n1)

install_pack_pkgurl
