#!/bin/sh

PKGNAME=draw.io
SUPPORTEDARCHES="x86_64"
DESCRIPTION="diagrams.net desktop"


. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

PKG=$(epm tool eget --list --latest https://github.com/jgraph/drawio-desktop/releases "drawio-$arch-[[:digit:]]*.$pkgtype") || fatal "Can't get package URL"

epm install "$PKG"
