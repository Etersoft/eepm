#!/bin/sh

PKGNAME=obsidian
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Obsidian from the official site'
URL="https://obsidian.md"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/obsidianmd/obsidian-releases/" "$PKGNAME*.$VERSION*$arch.$pkgtype")
else
    PKGURL=$(get_github_version "https://github.com/obsidianmd/obsidian-releases/" "$PKGNAME.*$VERSION.*$arch.$pkgtype")
fi

install_pkgurl
