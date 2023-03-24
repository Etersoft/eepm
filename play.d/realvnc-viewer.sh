#!/bin/sh

PKGNAME=realvnc-vnc-viewer
SUPPORTEDARCHES="x86_64 armhf aarch64"
DESCRIPTION="Real VNC Viewer from the official site"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"
arch="$(epm print info -a)"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

case $pkgtype-$arch in
    rpm-x86_64)
        PKG="VNC-Viewer-*-Linux-x64.rpm"
        ;;
    *-x86_64)
        PKG="VNC-Viewer-*-Linux-x64.deb"
        ;;
    *-aarch64)
        PKG="VNC-Viewer-*-Linux-ARM64.deb"
        ;;
    *-armhf)
        PKG="VNC-Viewer-*-Linux-ARM.deb"
        ;;
    *)
        fatal "Unsupported arch"
        ;;
esac

PKGURL=$(epm tool eget --list --latest https://www.realvnc.com/en/connect/download/viewer/ $PKG)

epm $repack install $PKGURL
