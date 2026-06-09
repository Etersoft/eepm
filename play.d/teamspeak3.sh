#!/bin/sh

PKGNAME=teamspeak3
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TeamSpeak3 Client for Linux from the official site"
URL="https://www.teamspeak.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(fetch_url https://teamspeak.com/en/downloads/ \
        | grep -oE 'https://files\.teamspeak-services\.com/releases/client/[0-9.]+/TeamSpeak3-Client-linux_amd64-[0-9.]+\.run' \
        | head -n1)"
else
    PKGURL="https://files.teamspeak-services.com/releases/client/$VERSION/TeamSpeak3-Client-linux_amd64-$VERSION.run"
fi

install_pack_pkgurl
