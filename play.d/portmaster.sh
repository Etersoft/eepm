#!/bin/sh

PKGNAME=portmaster
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Portmaster from the official site"
URL="https://safing.io/"

. $(dirname $0)/common.sh

repack=''
pkgtype="$(epm print info -p)"

case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        pkgtype="deb"
        ;;
esac

if [ "$(epm print info -s)" = "alt" ] ; then
    repack="--repack"
fi

PKGURL="https://updates.safing.io/latest/linux_amd64/packages/portmaster-installer.$pkgtype"

epm install $prepack "$PKGURL"
