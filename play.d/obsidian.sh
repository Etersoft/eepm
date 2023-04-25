#!/bin/sh

PKGNAME=obsidian
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Obsidian from the official site'

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

PKGURL=$(epm tool eget --list --latest https://github.com/obsidianmd/obsidian-releases/releases/ "$PKGNAME*$VERSION*$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKGURL"
