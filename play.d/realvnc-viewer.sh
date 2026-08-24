#!/bin/sh

PKGNAME=realvnc-vnc-viewer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Real VNC Viewer from the official site"
URL="https://www.realvnc.com/en/connect/download/viewer/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"

case $pkgtype in
    rpm) suffix=rpm ;;
    *) suffix=deb ;;
esac

[ "$VERSION" = "*" ] && VERSION=Latest
PKGURL="https://downloads.realvnc.com/download/file/realvnc-connect-viewer/RealVNC-Connect-Viewer-$VERSION-Linux-x64.$suffix"

install_pkgurl
