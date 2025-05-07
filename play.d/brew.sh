#!/bin/sh

PKGNAME=brew
SUPPORTEDARCHES=""
VERSION="$2"
DESCRIPTION="The missing package manager for macOS (or Linux)"
URL="https://github.com/Homebrew/brew/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag https://github.com/Homebrew/brew)
fi

PKGURL="https://github.com/Homebrew/brew/archive/refs/tags/$VERSION.tar.gz"

install_pack_pkgurl
