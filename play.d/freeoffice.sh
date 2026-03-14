#!/bin/sh

PKGNAME=softmaker-freeoffice
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SoftMaker Free Office from the official site"
TIPS="Run epm play freeoffice=<version> to install some specific version"
URL="https://www.freeoffice.com/en/support/installation/linux"

. $(dirname $0)/common.sh

# TODO: rpm and deb

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://www.freeoffice.com/en/support/installation/linux "softmaker-freeoffice-*-amd64.tgz")"
else
    PKGURL="https://www.softmaker.net/down/softmaker-freeoffice-2024-$VERSION-amd64.tgz"
fi

install_pack_pkgurl
