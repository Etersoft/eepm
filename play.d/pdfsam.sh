#!/bin/sh

PKGNAME=pdfsam-basic
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Free and open source, multi-platform software designed to extract pages, split, merge, mix and rotate PDF files.'
URL="https://github.com/torakiki/pdfsam"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/torakiki/pdfsam/" "${PKGNAME}_${VERSION}-1_amd64.deb")
else
    PKGURL="https://github.com/torakiki/pdfsam/releases/download/v${VERSION}/${PKGNAME}_${VERSION}-1_amd64.deb"
fi

install_pkgurl
