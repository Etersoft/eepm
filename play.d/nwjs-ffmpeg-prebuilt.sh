#!/bin/sh

PKGNAME='nwjs-ffmpeg-prebuilt'
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='FFmpeg prebuilt binaries for NW.js / Chromium from the official project site'
URL="https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt/" ".${VERSION}-linux-x64.zip")
else
    PKGURL="https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt/releases/download/$VERSION/$VERSION-linux-x64.zip"
fi

install_pack_pkgurl
