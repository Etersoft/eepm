#!/bin/sh

PKGNAME=realvnc-vnc-viewer
SUPPORTEDARCHES="x86_64 armhf aarch64"
VERSION="$2"
DESCRIPTION="Real VNC Viewer from the official site"
URL="https://www.realvnc.com/en/connect/download/vnc/"

. $(dirname $0)/common.sh

# vendor packages has shorted version, so drop latest version part (buildid)
if [ "$VERSION" != "*" ] ; then
    VERSION="$(echo "$VERSION" | sed -e 's|\.[0-9][0-9][0-9].*||')"
fi

pkgtype="$(epm print info -p)"
arch="$(epm print info -a)"

case $pkgtype-$arch in
    rpm-x86_64)
        PKG="VNC-Viewer-$VERSION-Linux-x64.rpm"
        ;;
    *-x86_64)
        PKG="VNC-Viewer-$VERSION-Linux-x64.deb"
        ;;
    *-aarch64)
        PKG="VNC-Viewer-$VERSION-Linux-ARM64.deb"
        ;;
    *-armhf)
        PKG="VNC-Viewer-$VERSION-Linux-ARM.deb"
        ;;
    *)
        fatal "Unsupported arch"
        ;;
esac

# https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-7.10.0-Linux-x64.deb
# https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-7.10.0-Linux-x64.rpm
PKGURL=$(eget --list --latest https://www.realvnc.com/en/connect/download/viewer/ "$PKG")

install_pkgurl
