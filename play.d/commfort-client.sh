#!/bin/sh

PKGNAME=commfort-client
SUPPORTEDARCHES="x86_64 x86"
# just a concept
DESCRIPTION='' #"CommFort WINE Edition from the official site"
URL="https://www.commfort.com/ru/article-commfort-linux.shtml"

. $(dirname $0)/common.sh

VERSION="5.96d"
# TODO: check: https://www.commfort.com/download/commfort_client.msi
INSTALLURL="https://www.commfort.com/download/commfort_client_wine.exe"

epm pack --install $PKGNAME $INSTALLURL $VERSION
