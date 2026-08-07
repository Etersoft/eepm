#!/bin/sh

PKGNAME=teamspeak
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TeamSpeak Client for Linux from the official site"
URL="https://www.teamspeak.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(fetch_url https://teamspeak.com/en/downloads/ \
        | grep -oE 'https://files\.teamspeak-services\.com/pre_releases/client/[0-9.]+-beta[0-9.]+/teamspeak-client\.tar\.gz' \
        | head -n1)"
else
    VERSION=${VERSION/.beta/-beta}
    PKGURL="https://files.teamspeak-services.com/pre_releases/client/$VERSION/teamspeak-client.tar.gz"
fi

[ -n "$PKGURL" ] || fatal "Can't get TeamSpeak client package URL from $URL"

install_pack_pkgurl
