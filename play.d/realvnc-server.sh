#!/bin/sh

PKGNAME=realvnc-vnc-server
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Real VNC Server from the official site"
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
        mask="VNC-Server-$VERSION-Linux-x64.rpm"
        ;;
    *-x86_64)
        mask="VNC-Server-$VERSION-Linux-x64.deb"
        ;;
    *)
        fatal "Unsupported arch"
        ;;
esac

PKGURL=$(eget --list --latest https://www.realvnc.com/en/connect/download/vnc/ "$mask")
install_pkgurl
