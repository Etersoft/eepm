#!/bin/sh

PKGNAME=upscayl
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Free and Open Source AI Image Upscaler'
URL="https://github.com/upscayl/upscayl"

. $(dirname $0)/common.sh

# FIXME: they put some wrong version to X-AppImage-Version
# https://github.com/upscayl/upscayl/issues/761
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/upscayl/upscayl/" "upscayl-.$VERSION-linux.AppImage")
else
    PKGURL="https://github.com/upscayl/upscayl/releases/download/v$VERSION/upscayl-$VERSION-linux.AppImage"
fi

install_pkgurl
