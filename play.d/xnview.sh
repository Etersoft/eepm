#!/bin/sh

PKGNAME=xnview
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="XnView MP: Image management from the official site"
URL="https://xnview.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://download.xnview.com/XnViewMP-linux-x64.deb"

epm install "$PKGURL"
