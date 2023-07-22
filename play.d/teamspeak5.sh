#!/bin/sh

PKGNAME=teamspeak5
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TeamSpeak5 Client for Linux from the official site"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION=5.0.0-beta73

PKGURL="https://files.teamspeak-services.com/pre_releases/client/$VERSION/teamspeak-client.tar.gz"

epm pack --install $PKGNAME "$PKGURL" $VERSION
