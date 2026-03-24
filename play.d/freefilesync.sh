#!/bin/sh

PKGNAME=freefilesync
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="FreeFileSync is a folder comparison and synchronization software that creates and manages backup copies of all your important files"
URL="https://freefilesync.org"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- "https://freefilesync.org/download.php" | grep -oE 'FreeFileSync_[0-9]+\.[0-9]+_Linux' | head -1 | sed 's|FreeFileSync_||;s|_Linux||')
    [ -n "$VERSION" ] || fatal "Can't get latest version"
fi

PKGURL="https://freefilesync.org/download/FreeFileSync_${VERSION}_Linux_x86_64.tar.gz"

install_pack_pkgurl
