#!/bin/sh

PKGNAME=libicu56
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION=""

. $(dirname $0)/common.sh

if [ "$(epm print info -s)" = "alt" ] ; then
    PKGURL="https://ftp.basealt.ru/pub/distributions/archive/p8/date/2018/01/04/x86_64/RPMS.classic/libicu56-5.6.1-alt1.1.x86_64.rpm"
    epm install $PKGURL
else
    epm install libicu56
fi

