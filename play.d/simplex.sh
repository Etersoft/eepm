#!/bin/sh

PKGNAME=simplex
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The first messaging network operating without user identifiers of any kind'
URL="https://github.com/simplex-chat/simplex-chat"

. $(dirname $0)/common.sh


if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/simplex-chat/simplex-chat" "simplex-desktop-ubuntu-22_04-x86_64.deb")
else
    PKGURL="https://github.com/simplex-chat/simplex-chat/releases/download/v$VERSION/simplex-desktop-ubuntu-22_04-x86_64.deb"
fi

install_pkgurl

