#!/bin/sh

PKGNAME=portmaster
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Portmaster from the official site"
URL="https://safing.io/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"

case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        pkgtype="deb"
        ;;
esac

PKGURL="https://updates.safing.io/latest/linux_amd64/packages/portmaster-installer.$pkgtype"

install_pkgurl
