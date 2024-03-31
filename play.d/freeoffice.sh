#!/bin/sh

PKGNAME=softmaker-freeoffice-2021
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SoftMaker Free Office from the official site"
TIPS="Run epm play freeoffice=<version> to install some specific version"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        file="softmaker-freeoffice-$VERSION*.x86_64.rpm"
        ;;
    *)
        file="softmaker-freeoffice-$VERSION*_amd64.deb"
        ;;
esac

PKGURL="$(eget --list --latest https://www.freeoffice.com/ru/download/applications "$file")"

install_pkgurl
