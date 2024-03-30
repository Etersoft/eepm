#!/bin/sh

PKGNAME=flashplayer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Adobe Flash Player from the official site"
URL="https://www.adobe.com/support/flashplayer/downloads.html"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION=32.0.0.465
PKGURL="https://fpdownload.macromedia.com/pub/flashplayer/updaters/32/flash_player_sa_linux.x86_64.tar.gz"

epm pack --install $PKGNAME $PKGURL "$VERSION"
