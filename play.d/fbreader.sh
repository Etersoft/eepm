#!/bin/sh

PKGNAME=FBReader_Book_Reader
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="An ePub reader supporting Readium LCP DRM. Also opens fb2 and other formats. Free, fast, configurable"
URL="https://fbreader.org/en/linux"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=$(epm print info -a)

if [ "$VERSION" = "*" ]; then
    VERSION=$(eget -O- https://fbreader.org/en/linux/packages | grep -o -m 1 "FBReader [0-9].[0-9].[0-9]" | awk '{print $2}')
fi 

PKGURL="https://fbreader.org/static/packages/linux/FBReader_Book_Reader-$arch-$VERSION.AppImage"

install_pkgurl
