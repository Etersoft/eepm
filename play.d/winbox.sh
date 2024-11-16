#!/bin/sh

PKGNAME=winbox
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Winbox from the official site'
URL="https://mikrotik.com/download"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- https://mikrotik.com/download | grep WinBox_Linux.zip | awk -F'/' '{print $6}' | head -n1)
fi
PKGURL="https://download.mikrotik.com/routeros/winbox/$VERSION/WinBox_Linux.zip"

install_pack_pkgurl
