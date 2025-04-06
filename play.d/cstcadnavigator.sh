#!/bin/sh

PKGNAME=cstcadnavigator
VERSION="$2"
SUPPORTEDARCHES="x86_64"
DESCRIPTION="CST CAD Navigator from the official site"
URL="https://cadsofttools.ru/products/cst-cad-navigator/download/"

. $(dirname $0)/common.sh

# Используются одни и те же бинарники в deb и rpm
# но файл rpm с версией, поэтому нам предпочтительнее для истории
if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://cadsofttools.ru/products/cst-cad-navigator/download/ "$PKGNAME-*x86_64.rpm" )"
else
    PKGURL="https://cadsofttools.ru/download/cstcadnavigator-$VERSION-1.x86_64.rpm"
fi

install_pkgurl
