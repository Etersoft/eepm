#!/bin/sh

PKGNAME=teamspeak3
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TeamSpeak3 Client for Linux from the official site"
URL="https://www.teamspeak.com/"

. $(dirname $0)/common.sh

# TODO: check latest version here: https://www.teamspeak.com/en/downloads/#ts3client
[ "$VERSION" = "*" ] && VERSION=3.6.1

PKGURL="https://files.teamspeak-services.com/releases/client/$VERSION/TeamSpeak3-Client-linux_amd64-$VERSION.run"

epm pack --install $PKGNAME "$PKGURL"
