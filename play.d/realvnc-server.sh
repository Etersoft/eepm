#!/bin/sh

PKGNAME=realvnc-vnc-server
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Real VNC Server from the official site"
URL="https://www.realvnc.com/en/connect/download/vnc/"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"
arch="$(epm print info -a)"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

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

PKGURL=$(eget --list --latest https://www.realvnc.com/en/connect/download/vnc/ "$mask") || fatal "Can't get package URL"

epm $repack install $PKGURL
