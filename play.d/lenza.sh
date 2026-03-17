#!/bin/sh

PKGNAME=Lenza
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Lenza — мессенджер для общения в твоей команде'
URL="https://lenzaos.com/"

. $(dirname $0)/common.sh

if ! is_glibc_enough 2.34 ; then
    fatal "glibc is too old"
fi

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- https://software.lenzaos.com/app-chats/latest-linux.yml | awk -F': ' '/^version:/{print $2; exit}' | tr -d '\r')
fi

PKGURL="https://software.lenzaos.com/app-chats/$PKGNAME-$VERSION.AppImage"

install_pkgurl
