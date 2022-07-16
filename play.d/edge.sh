#!/bin/sh

BASEPKGNAME=microsoft-edge
SUPPORTEDARCHES="x86_64"
PRODUCTALT="stable beta dev"
DESCRIPTION="Microsoft Edge browser (dev) from the official site"

BRANCH=stable
for i in $PRODUCTALT ; do
    if [ "$2" = "$i" ] || epm installed $BASEPKGNAME-$i ; then
        BRANCH="$i"
    fi
done
PKGNAME=$BASEPKGNAME-$BRANCH


. $(dirname $0)/common.sh

# epm uses eget to download * names
epm install "https://packages.microsoft.com/repos/edge/pool/main/m/$PKGNAME/${PKGNAME}_*_amd64.deb"
