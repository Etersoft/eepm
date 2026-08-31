#!/bin/sh

PKGNAME=crosspaste
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Cross-platform clipboard sharing and file transfer"
URL="https://github.com/CrossPaste/crosspaste-desktop"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"

# https://github.com/CrossPaste/crosspaste-desktop/releases/download/2.1.7.2461/crosspaste_2.1.7-2461_amd64.deb
if [ "$VERSION" = "*" ] || [ "$RELEASE" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "crosspaste_*_${arch}.deb")"
else
    PKGURL="$URL/releases/download/$VERSION.$RELEASE/crosspaste_${VERSION}-${RELEASE}_${arch}.deb"
fi

install_pkgurl
