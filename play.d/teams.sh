#!/bin/sh

PKGNAME=teams
SUPPORTEDARCHES="x86_64"
VERSION="$2"
# After April 12, 2023, Microsoft Teams Free (classic), the legacy free Teams app for business, will no longer be available.
# https://www.microsoft.com/en-us/microsoft-teams/free-classic-retirement?rtc=1
DESCRIPTION="Microsoft Teams for Linux from the archive.org of the official site"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

# archive.org have only deb packages
#pkgtype=deb

if [ "$pkgtype" = "deb" ] ; then
    URL="https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams"
    arch=amd64
    [ "$VERSION" = "*" ] && VERSION="[0-9]*"
else
    URL="https://packages.microsoft.com/yumrepos/ms-teams"
    arch=x86_64
    pkgtype=rpm
    [ "$VERSION" = "*" ] && VERSION="[0-9]*" || VERSION="$VERSION-1"
fi

# rpm and deb contains the same binaries
# $ diff -ru teams-1.5.00.23861-1.x86_64 teams_1.5.00.23861_amd64
ARCHIVEORG=https://web.archive.org/web/20221130114832if_

PKGURL="$ARCHIVEORG/$URL/$(epm print constructname teams "$VERSION" $arch $pkgtype)"

install_pkgurl
