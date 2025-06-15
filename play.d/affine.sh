#!/bin/sh

PKGNAME=affine
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='There can be more than Notion and Miro.AFFiNE is a next-gen knowledge base that brings planning, sorting and creating all together. Privacy first, open-source, customizable and ready to use'
URL="https://github.com/toeverything/AFFiNE"

. $(dirname $0)/common.sh

arch=x64
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/toeverything/AFFiNE/" "${PKGNAME}-${VERSION}-stable-linux-$arch.appimage")
else
    PKGURL="https://github.com/toeverything/AFFiNE/releases/download/v$VERSION/${PKGNAME}-${VERSION}-stable-linux-$arch.appimage"
fi

install_pkgurl
