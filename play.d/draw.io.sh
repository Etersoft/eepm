#!/bin/sh

PKGNAME=draw.io
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="diagrams.net desktop"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/jgraph/drawio-desktop/" "drawio-$arch-.$VERSION.$pkgtype")
else
    PKGURL="https://github.com/jgraph/drawio-desktop/releases/download/v$VERSION/drawio-$arch-$VERSION.$pkgtype"
fi

install_pkgurl
