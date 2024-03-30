#!/bin/sh

PKGNAME=pantum
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="CUPS and SANE drivers for Pantum series printer and scanner"
URL="https://www.pantum.ru/support/download/driver/"

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME printer-driver-pantum
    exit
fi

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://drivers.pantum.ru/userfiles/files/download/%E9%A9%B1%E5%8A%A8%E6%96%87%E4%BB%B6/2013/Pantum%20Ubuntu%20Driver%20V1_1_99-1.zip"

epm pack --install $PKGNAME "$PKGURL" || exit

PKGURL="https://drivers.pantum.ru/userfiles/files/download/%E9%A9%B1%E5%8A%A8%E6%96%87%E4%BB%B6/%E6%A0%87%E7%AD%BE%E6%9C%BA/Linux/linux_pantum.7z"

epm pack --install $PKGNAME "$PKGURL"
