#!/bin/sh

PKGNAME=draw.io
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="diagrams.net desktop"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

PKGURL=$(epm tool eget --list --latest https://github.com/jgraph/drawio-desktop/releases "drawio-$arch-$VERSION.$pkgtype") || fatal "Can't get package URL"

epm install "$PKGURL"
