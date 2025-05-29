#!/bin/sh

PKGNAME=Lenza
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Lenza — мессенджер для общения в твоей команде'
URL="https://lenzaos.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- https://lenzaos.com/ | grep -oP 'Lenza-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.AppImage)')
fi

PKGURL="https://software.lenzaos.com/app-chats/$PKGNAME-$VERSION.AppImage"

install_pkgurl
