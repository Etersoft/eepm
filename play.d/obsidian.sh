#!/bin/sh

PKGNAME=obsidian
DESCRIPTION='Obsidian from the official site'

. $(dirname $0)/common.sh

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

arch=amd64
pkgtype=deb

PKG=$($EGET --list --latest https://github.com/obsidianmd/obsidian-releases/releases/ "$PKGNAME*$arch.$pkgtype") || fatal "Can't get package URL"
[ -n "$PKG" ] || fatal "Can't get package URL"

epm install "$PKG"
