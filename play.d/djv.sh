#!/bin/sh

PKGNAME=DJV2
SUPPORTEDARCHES="x86_64"
DESCRIPTION="DVJ - Professional media review software for VFX, animation, and film production"


. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        mask="DJV2-*.x86_64.rpm"
        ;;
    deb)
        mask="DJV2_*_amd64.deb"
        ;;
esac

arch=amd64

PKGURL=$(epm tool eget --list --latest https://github.com/darbyjohnston/DJV/releases $mask) || fatal "Can't get package URL"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL"
