#!/bin/sh

PKGNAME=upscayl
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Free and Open Source AI Image Upscaler'
URL="https://github.com/upscayl/upscayl"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/upscayl/upscayl" "${PKGNAME}-${VERSION}-linux.AppImage")
else
    PKGURL="https://github.com/upscayl/upscayl/releases/download/v$VERSION/${PKGNAME}-${VERSION}-linux.AppImage"
fi

install_pkgurl
