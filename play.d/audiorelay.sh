#!/bin/sh

PKGNAME=audiorelay
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="AudioRelay from the official site"
URL="https://audiorelay.net"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION="0.27.5"

# https://audiorelay.net/downloads
# TODO: https://api.audiorelay.net/downloads
epm install "https://dl.audiorelay.net/setups/linux/audiorelay-$VERSION.deb"
