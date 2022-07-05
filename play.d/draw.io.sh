#!/bin/sh

PKGNAME=draw.io
DESCRIPTION="diagrams.net desktop"


. $(dirname $0)/common.sh

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1


arch=amd64
pkgtype=deb

PKG=$(epm tool eget --list --latest https://github.com/jgraph/drawio-desktop/releases "drawio-$arch-[[:digit:]]*.$pkgtype") || fatal "Can't get package URL"

epm install "$PKG"
