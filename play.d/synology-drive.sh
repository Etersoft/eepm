#!/bin/sh

PKGNAME=synology-drive
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Synology Drive Client from the official site'
URL="https://www.synology.com/"

. $(dirname $0)/common.sh

is_stdcpp_enough "11.0" || VERSION="3.4.29" && info "libstdc++ version below 11.0, we'll stick with the old version $VERSION"

if ! is_glibc_enough 2.34 ; then
    fatal "Версия glibc слишком старая, требуется система с glibc 2.34 и выше."
fi


[ "$VERSION" = "*" ] && VERSION="[0-9]*"

# it is so strange, package name contains 3.x.x, but package version is 7.x.x
VERSION="$(echo "$VERSION" | sed -e 's|^7|3|' -e 's|^8|4')"

urldir="$(eget --list https://archive.synology.com/download/Utility/SynologyDriveClient "/$VERSION-*" | head -n1)"
[ -n "$urldir" ] || fatal "Can't get dir for $VERSION version on https://archive.synology.com/download/Utility/SynologyDriveClient"

PKGURL="$urldir/$PKGNAME-*.x86_64.deb"

install_pkgurl
