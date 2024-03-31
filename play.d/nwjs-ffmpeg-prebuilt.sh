#!/bin/sh

PKGNAME='nwjs-ffmpeg-prebuilt'
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='FFmpeg prebuilt binaries for NW.js / Chromium from the official project site'
URL="https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt/"

. $(dirname $0)/common.sh

# https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt/releases/download/0.85.0/0.85.0-linux-x64.zip
PKGURL=$(eget --list --latest https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt/releases "${VERSION}-linux-x64.zip")

install_pack_pkgurl
