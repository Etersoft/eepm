#!/bin/sh

PKGNAME=rats-search
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='A BitTorrent search program for desktop and web'
URL="https://github.com/librats/rats-search"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "RatsSearch-Linux-x64-v$VERSION.AppImage")"
elif is_version_older "$VERSION" 2.0.0 ; then
    # Upstream changed AppImage file names in 2.0.0.
    PKGURL="$URL/releases/download/v$VERSION/rats-search-$VERSION-x86_64.AppImage"
else
    PKGURL="$URL/releases/download/v$VERSION/RatsSearch-Linux-x64-v$VERSION.AppImage"
fi

install_pkgurl
