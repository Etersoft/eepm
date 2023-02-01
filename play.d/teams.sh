#!/bin/sh

PKGNAME=teams
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Microsoft Teams for Linux from the official site"

. $(dirname $0)/common.sh

repack=''
pkgtype="$($DISTRVENDOR -p)"

if [ "$pkgtype" = "deb" ] ; then
    URL="https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams"
    arch=amd64
else
    URL="https://packages.microsoft.com/yumrepos/ms-teams/Packages/t"
    arch=x86_64
    pkgtype=rpm
fi

if [ "$($DISTRVENDOR -s)" = "alt" ] ; then
    repack="--repack"
fi

# rpm and deb contains the same binaries
# $ diff -ru teams-1.5.00.23861-1.x86_64 teams_1.5.00.23861_amd64

# epm uses eget to download * names
epm install $repack "$URL/$(epm print constructname teams "[0-9]*" $arch $pkgtype)"
