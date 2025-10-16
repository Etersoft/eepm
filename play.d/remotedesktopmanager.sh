#!/bin/sh
PKGNAME="RemoteDesktopManager remotedesktopmanager"
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Centralize, Manage and Secure Remote Connections"
URL="https://devolutions.net/remote-desktop-manager/downloadfree/"

. $(dirname $0)/common.sh


pkgtype="$(epm print info -p)"
debarch="$(epm print info --debian-arch)"
rpmarch="$(epm print info -a)"

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- https://devolutions.net/remote-desktop-manager/release-notes/linux/ | grep -oP -m 1 '(?<=Version )\d+\.\d+\.\d+\.\d+' )
fi

case "$pkgtype" in
    rpm)
        # CamelCase in RPM name
        file="RemoteDesktopManager_${VERSION}_${rpmarch}.rpm" ;;
    *)
        # lowercase in DEBIAN/control
        file="RemoteDesktopManager_${VERSION}_${debarch}.deb" ;;
esac

PKGURL="https://cdn.devolutions.net/download/Linux/RDM/${VERSION}/${file}"

install_pkgurl

