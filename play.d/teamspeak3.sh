#!/bin/sh

PKGNAME=teamspeak3
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TeamSpeak3 Client for Linux from the official site"
URL="https://www.teamspeak.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- https://teamspeak.com/en/downloads/#ts3client | grep -oP 'https://files\.teamspeak-services\.com/releases/client/3\.\d+\.\d+/TeamSpeak3-Client-linux_amd64-3\.(\d+\.\d+)\.run' | head -n 1 | grep -oP '3\.(\d+\.\d+)' | head -n 1)
fi

PKGURL="https://files.teamspeak-services.com/releases/client/$VERSION/TeamSpeak3-Client-linux_amd64-$VERSION.run"

install_pack_pkgurl
