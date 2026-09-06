#!/bin/sh

PKGNAME=QtScrcpy
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="QtScrcpy - display and control Android devices via USB or network"
URL="https://github.com/barry-ran/QtScrcpy"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag "$URL")"
    [ -n "$VERSION" ] || fatal "Can't get version from GitHub"
fi

PKGURL="$URL/releases/download/v$VERSION/QtScrcpy-ubuntu-x64-v$VERSION.AppImage"

install_pack_pkgurl "$VERSION"
