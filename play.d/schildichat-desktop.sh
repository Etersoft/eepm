#!/bin/sh

PKGNAME=schildichat-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Matrix client / Element Web / Desktop fork'
URL="https://schildi.chat/"

. $(dirname $0)/common.sh

# Version support is temporarily disabled due to the use of unusual version suffix
warn_version_is_not_supported

pkgtype="$(epm print info -p)"

case $pkgtype in
    rpm)
        mask="${PKGNAME}-${VERSION}.x86_64.rpm"
        ;;
    deb|*)
        mask="${PKGNAME}_${VERSION}_amd64.deb"
        ;;
esac

PKGURL=$(get_github_url "https://github.com/SchildiChat/schildichat-desktop/" "$mask")

install_pkgurl

