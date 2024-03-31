#!/bin/sh

PKGNAME=DJV2
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="DJV2 - Professional media review software for VFX, animation, and film production"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        mask="DJV2-${VERSION}-[1-9].x86_64.rpm"
        ;;
    *)
        mask="DJV2_${VERSION}_amd64.deb"
        ;;
esac

arch=amd64

PKGURL=$(eget --list --latest https://github.com/darbyjohnston/DJV/releases "$mask") || fatal "Can't get package URL"

install_pkgurl
