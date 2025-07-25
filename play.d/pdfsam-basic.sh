#!/bin/sh

PKGNAME=pdfsam-basic
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="is free and open source desktop application to split, merge, extract pages, rotate and mix PDF files"
URL="https://pdfsam.org/"

. $(dirname $0)/common.sh

#pdfsam-basic_5.3.2-1_amd64.deb
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/torakiki/pdfsam/" "${PKGNAME}_${VERSION}-1_amd64.deb")
else
    PKGURL="https://github.com/torakiki/pdfsam/releases/download/v$VERSION/${PKGNAME}_${VERSION}-1_amd64.deb"
fi

install_pkgurl
