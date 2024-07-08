#!/bin/sh

PKGNAME=neovide
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="No Nonsense Neovim Client in Rust from the official site"
URL="https://neovide.dev/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/neovide/neovide/" "$PKGNAME.AppImage")
else
    PKGURL="https://github.com/neovide/neovide/releases/download/$VERSION/$PKGNAME.AppImage"
fi

install_pkgurl
