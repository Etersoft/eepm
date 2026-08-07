#!/bin/sh

PKGNAME=teamspeak
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TeamSpeak Client for Linux from the official site"
URL="https://www.teamspeak.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list https://teamspeak.com/en/downloads/ teamspeak-client.tar.gz)"
else
    VERSION=${VERSION/.beta/-beta}
    PKGURL="https://files.teamspeak-services.com/pre_releases/client/$VERSION/teamspeak-client.tar.gz"
fi

install_pack_pkgurl
