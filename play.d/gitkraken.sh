#!/bin/sh

PKGNAME=gitkraken
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="GitKraken Client from the official site"
URL="https://www.gitkraken.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://release.gitkraken.com/linux/gitkraken-amd64.rpm"
        ;;
    *)
        PKGURL="https://release.gitkraken.com/linux/gitkraken-amd64.deb"
        ;;
esac

install_pkgurl
