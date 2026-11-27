#!/bin/sh

PKGNAME=space-client
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Space Client (SpaceVM VDI thin client) from the official site"
URL="https://spacevm.ru"
TIPS="To redirect USB devices via USBIP add the user to the space_usbip group: usermod -a -G space_usbip <user>. The LoudPlay streaming protocol needs a separate loudplay-client package (not installed)."

. $(dirname $0)/common.sh

# the RED OS 8 build is the most recent one (ALT apt-rpm repo there is outdated)
BASEURL="https://update.spacevm-service.ru/space-client/linux/yum/redos8/x86_64/Packages"

# https://update.spacevm-service.ru/space-client/linux/yum/redos8/x86_64/Packages/space-client-3.8.3.1270-0.red80.x86_64.rpm
if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest "$BASEURL/" "$PKGNAME-*.red80.x86_64.rpm")"
else
    [ -n "$RELEASE" ] && [ "$RELEASE" != "*" ] || RELEASE="0.red80"
    PKGURL="$BASEURL/$PKGNAME-$VERSION-$RELEASE.x86_64.rpm"
fi

install_pkgurl || exit

echo
info 'To redirect USB devices via USBIP add the user to the space_usbip group: usermod -a -G space_usbip <user>'
