#!/bin/sh

PKGNAME=realvnc-vnc-server
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Real VNC Server from the official site"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"
arch="$(epm print info -a)"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

case $pkgtype-$arch in
    rpm-x86_64)
        PKG="VNC-Server-*-Linux-x64.rpm"
        ;;
    *-x86_64)
        PKG="VNC-Server-*-Linux-x64.deb"
        ;;
    *)
        fatal "Unsupported arch"
        ;;
esac

PKGURL=$(epm tool eget --list --latest https://www.realvnc.com/en/connect/download/vnc/ $PKG)

epm $repack install $PKGURL
