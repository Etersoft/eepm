#!/bin/sh

PKGNAME=wiimplay
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='WiiM Play - GTK3 UPnP control point for WiiM music streamers'
URL="https://github.com/shumatech/wiimplay"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag https://github.com/shumatech/wiimplay)"
fi
VERSION="${VERSION#v}"

PKGURL="https://github.com/shumatech/wiimplay/releases/download/v$VERSION/wiimplay"

install_pack_pkgurl $VERSION
