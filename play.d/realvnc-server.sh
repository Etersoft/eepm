#!/bin/sh

PKGNAME=realvnc-vnc-server
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Real VNC Server from the official site"
URL="https://www.realvnc.com/en/connect/download/vnc/"

. $(dirname $0)/common.sh

# vendor packages has shorted version, so drop latest version part (buildid)
if [ "$VERSION" != "*" ] ; then
    VERSION="$(echo "$VERSION" | cut -d'.' -f1-3)"
fi

pkgtype="$(epm print info -p)"
arch="$(epm print info -a)"

case $pkgtype-$arch in
    rpm-x86_64)
        mask="VNC-Server-$VERSION-Linux-x64.rpm"
        ;;
    *-x86_64)
        mask="VNC-Server-$VERSION-Linux-x64.deb"
        ;;
    *)
        fatal "Unsupported arch"
        ;;
esac

# https://downloads.realvnc.com/download/file/vnc.files/VNC-Server-7.15.0-Linux-x64.deb
if [ "$VERSION" = "*" ] ; then 
    PKGURL=$(eget --list --latest https://www.realvnc.com/en/connect/download/vnc/ "$mask")
else
    PKGURL="https://downloads.realvnc.com/download/file/vnc.files/$mask"
fi

install_pkgurl
