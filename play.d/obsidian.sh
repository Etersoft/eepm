#!/bin/sh

PKGNAME=obsidian
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Obsidian from the official site'

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

PKG=$(epm tool eget --list --latest https://github.com/obsidianmd/obsidian-releases/releases/ "$PKGNAME*$arch.$pkgtype") || fatal "Can't get package URL"
[ -n "$PKG" ] || fatal "Can't get package URL"

epm install "$PKG"
