#!/bin/sh

PKGNAME=apple-emoji-linux
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Apple Color Emoji font for Linux"
URL="https://github.com/samuelngs/apple-emoji-linux"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url "$URL" "AppleColorEmoji.ttf")

install_pack_pkgurl
