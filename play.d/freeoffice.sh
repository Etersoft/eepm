#!/bin/sh

PKGNAME=softmaker-freeoffice
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SoftMaker Free Office from the official site"
TIPS="Run epm play freeoffice=<version> to install some specific version"
URL="https://www.freeoffice.com/ru/download/applications"

. $(dirname $0)/common.sh

# TODO: rpm and deb
YEAR=2024

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://www.freeoffice.com/ru/download/applications "softmaker-freeoffice-$YEAR-$VERSION-amd64.tgz")"
else
    PKGURL="https://www.softmaker.net/down/softmaker-freeoffice-$YEAR-$VERSION-amd64.tgz"
fi

install_pack_pkgurl
