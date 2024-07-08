#!/bin/sh

PKGNAME=YouTube-Music
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="YouTube Music Desktop App bundled with custom plugins (and built-in ad blocker / downloader)"
URL="https://github.com/th-ch/youtube-music"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/th-ch/youtube-music/" "YouTube-Music-.$VERSION.AppImage")
else
    PKGURL="https://github.com/th-ch/youtube-music/releases/download/v$VERSION/YouTube-Music-$VERSION.AppImage"
fi

install_pkgurl
