#!/bin/sh

PKGNAME=logseq
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Logseq - a platform for knowledge management and collaboration. From the official site'
URL="https://github.com/logseq/logseq"

. $(dirname $0)/common.sh

# https://github.com/logseq/logseq/releases/download/0.9.5/Logseq-linux-x64-0.9.5.AppImage
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/logseq/logseq/" "Logseq-linux-x64-.$VERSION.AppImage")
else
    PKGURL="https://github.com/logseq/logseq/releases/download/$VERSION/Logseq-linux-x64-$VERSION.AppImage"
fi

install_pack_pkgurl
