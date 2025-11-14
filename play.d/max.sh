#!/bin/sh

PKGNAME=max
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Быстрое и лёгкое приложение для общения и решения повседневных задач'
URL="https://max.ru/"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://download.max.ru/electron/MAX.rpm"
        ;;
    *)
        PKGURL="https://download.max.ru/electron/MAX.deb"
        ;;
esac

install_pkgurl
