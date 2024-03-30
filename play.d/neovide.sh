#!/bin/sh

PKGNAME=neovide
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="No Nonsense Neovim Client in Rust from the official site"
URL="https://neovide.dev/"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/neovide/neovide/releases $PKGNAME.AppImage) || fatal "Can't get package URL"

epm install "$PKGURL"

