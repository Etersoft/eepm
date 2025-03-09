#!/bin/sh

PKGNAME=jazz
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Online meeting service from the official site"
URL="https://salutejazz.ru/"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
case $pkgtype in
    deb)
        PKGURL="https://dl.salutejazz.ru/desktop/latest/jazz.deb" ;;
    *)
        PKGURL="https://dl.salutejazz.ru/desktop/latest/jazz.AppImage" ;;
esac

install_pkgurl
