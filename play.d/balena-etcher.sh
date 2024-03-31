#!/bin/sh

PKGNAME=balena-etcher
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Flash OS images to SD cards & USB drives, safely and easily"
URL="https://etcher.io/"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        mask="balena-etcher-${VERSION}-[1-9].x86_64.rpm"
        ;;
    *)
        mask="balena-etcher_${VERSION}_amd64.deb"
        ;;
esac

PKGURL=$(eget --list --latest https://github.com/balena-io/etcher/releases "$mask") || fatal "Can't get package URL"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL"
