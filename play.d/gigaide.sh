#!/bin/sh

PKGNAME=gigaideCE
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='GIGA IDE CE — IDE based on IDEA/PyCharm'
URL="https://gitverse.ru/features/gigaide/#desktop"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://gitverse.ru/features/gigaide/desktop/download/ $PKGNAME-$VERSION.tar.gz)"
else
    PKGURL="https://gigaide.ru/downloadlast/$PKGNAME-$VERSION.tar.gz"
fi

install_pkgurl

