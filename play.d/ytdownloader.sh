#!/bin/sh

PKGNAME=ytdownloader
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A modern GUI video and audio downloader supporting hundreds of sites"
URL="https://github.com/aandrew-me/ytDownloader"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "YTDownloader_Linux.deb")
else
    PKGURL="$URL/releases/download/v$VERSION/YTDownloader_Linux.deb"
fi

install_pkgurl
