#!/bin/sh

PKGNAME=YouTube-Music
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="YouTube Music Desktop App bundled with custom plugins (and built-in ad blocker / downloader)"
URL="https://github.com/th-ch/youtube-music"

. $(dirname $0)/common.sh

PKGURL="$(eget --list --latest https://github.com/th-ch/youtube-music/releases/ "YouTube-Music-$VERSION.AppImage")"

epm install "$PKGURL"
