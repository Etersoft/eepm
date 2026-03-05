#!/bin/sh

PKGNAME=cstcadnavigator
VERSION="$2"
RELEASE="$3"
SUPPORTEDARCHES="x86_64"
DESCRIPTION="CST CAD Navigator from the official site"
URL="https://cadsofttools.ru/products/cst-cad-navigator/download/"

. $(dirname $0)/common.sh

# Используются одни и те же бинарники в deb и rpm
# но файл rpm с версией, поэтому нам предпочтительнее для истории
if [ "$VERSION" = "*" ] ; then
    # eget resolves relative links from the page, which may produce doubled /download/download/
    PKGURL="$(eget --list --latest https://cadsofttools.ru/products/cst-cad-navigator/download/ "$PKGNAME-*x86_64.rpm" | sed 's|.*/download/|https://cadsofttools.ru/download/|')"
else
    PKGURL="https://cadsofttools.ru/download/cstcadnavigator-${VERSION}-${RELEASE}.x86_64.rpm"
fi

install_pkgurl
