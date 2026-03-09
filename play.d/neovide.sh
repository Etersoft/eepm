#!/bin/sh

PKGNAME=neovide
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="No Nonsense Neovim Client in Rust from the official site"
URL="https://github.com/neovide/neovide"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "$PKGNAME.AppImage")
else
    PKGURL="$URL/releases/download/$VERSION/$PKGNAME.AppImage"
fi

install_pkgurl

