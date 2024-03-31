#!/bin/sh

PKGNAME=obsidian
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Obsidian from the official site'
URL="https://obsidian.md"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

PKGURL=$(eget --list --latest https://github.com/obsidianmd/obsidian-releases/releases/ "$PKGNAME*$VERSION*$arch.$pkgtype") || fatal "Can't get package URL"

install_pkgurl
