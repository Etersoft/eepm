#!/bin/sh

PKGNAME=teamspeak3
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TeamSpeak3 Client for Linux from the official site"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION=3.6.0

PKGURL="https://files.teamspeak-services.com/releases/client/$VERSION/TeamSpeak3-Client-linux_amd64-$VERSION.run"

epm pack --install $PKGNAME "$PKGURL"
