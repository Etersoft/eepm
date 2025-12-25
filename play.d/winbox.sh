#!/bin/sh

PKGNAME=winbox
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Winbox from the official site'
URL="https://mikrotik.com/download"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(eget --list --latest https://mikrotik.com/download/winbox "WinBox_Linux.zip")
else
    PKGURL="https://download.mikrotik.com/routeros/winbox/$VERSION/WinBox_Linux.zip"
fi

install_pack_pkgurl
