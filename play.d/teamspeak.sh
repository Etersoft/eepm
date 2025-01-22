#!/bin/sh

PKGNAME=teamspeak
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TeamSpeak Client for Linux from the official site"
URL="https://www.teamspeak.com/"

. $(dirname $0)/common.sh

# Why we need this ?
warn_version_is_not_supported

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- https://teamspeak.com/en/downloads/ | grep -oP 'https://files\.teamspeak-services\.com/pre_releases/client/([\.\-beta\d]+)' | head -n 1 | grep -oP '([\.\-beta\d]+)' | tail -n 1)
fi

PKGURL="https://files.teamspeak-services.com/pre_releases/client/$VERSION/teamspeak-client.tar.gz"

install_pack_pkgurl "$VERSION"
