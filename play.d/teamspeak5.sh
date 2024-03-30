#!/bin/sh

PKGNAME=teamspeak5
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TeamSpeak5 Client for Linux from the official site"
URL="https://www.teamspeak.com/"

. $(dirname $0)/common.sh

# TODO: check latest version here: https://www.teamspeak.com/en/downloads/#ts5client
[ "$VERSION" = "*" ] && VERSION=5.0.0-beta77

PKGURL="https://files.teamspeak-services.com/pre_releases/client/$VERSION/teamspeak-client.tar.gz"

epm pack --install $PKGNAME "$PKGURL" $VERSION
