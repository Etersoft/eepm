#!/bin/sh

PKGNAME=gemini-cli
SUPPORTEDARCHES="x86_64 aarch64" # any
VERSION="$2"
DESCRIPTION="An open-source AI agent that brings the power of Gemini directly into your terminal"
URL="https://github.com/google-gemini/gemini-cli"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url $URL "gemini.js")

install_pack_pkgurl
