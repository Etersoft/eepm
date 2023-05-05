#!/bin/sh

PKGNAME=gitkraken
SUPPORTEDARCHES="x86_64"
DESCRIPTION="GitKraken Client from the official site"
URL="https://www.gitkraken.com/"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://release.gitkraken.com/linux/gitkraken-amd64.rpm"
        ;;
    *)
        PKGURL="https://release.gitkraken.com/linux/gitkraken-amd64.deb"
        ;;
esac

epm install "$PKGURL"
