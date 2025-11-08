#!/bin/sh

PKGNAME=zen-browser
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Performance oriented Firefox-based web browser"
URL="https://github.com/zen-browser/desktop"

. $(dirname $0)/common.sh

arch=$(epm print info -a)

warn_version_is_not_supported

PKGURL=$(get_github_url "https://github.com/zen-browser/desktop/" "zen-${arch}.AppImage")

install_pack_pkgurl
