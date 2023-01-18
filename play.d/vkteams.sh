#!/bin/sh

PKGNAME=vkteams
SUPPORTEDARCHES="x86_64"
DESCRIPTION="VK Teams for Linux from the official site"

. $(dirname $0)/common.sh

# TODO:
VERSION="1.0"

PKGURL="https://vkteams-www.hb.bizmrg.com/linux/x64/vkteams.tar.xz"
PKGFILE="/tmp/$PKGNAME-$VERSION.tar.xz"

epm tool eget -O $PKGFILE $PKGURL || exit

epm install --repack "$PKGFILE" || exit
