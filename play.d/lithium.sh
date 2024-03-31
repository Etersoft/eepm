#!/bin/sh

# TODO: uses global epm here
pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGNAME=lithium_ecad
        ;;
    *)
        PKGNAME=lithium-ecad
        ;;
esac

SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="CAD of printed circuit boards"
URL="https://www.lecad.ru"

. $(dirname $0)/common.sh

case $pkgtype in
    rpm)
        mask="$PKGNAME-$VERSION*.x86_64.rpm"
        ;;
    *)
        mask="$PKGNAME_$VERSION*_amd64.deb"
        ;;
esac

# https://www.lecad.ru/?download=&kcccount=https://www.lecad.ru/wp-content/uploads/lithium-ecad_1.7.5_amd64.deb
# https://www.lecad.ru/?download=&kcccount=https://www.lecad.ru/wp-content/uploads/lithium_ecad-1.7.5-0.x86_64.rpm
PKGURL="$(eget --list --latest https://www.lecad.ru/actual-version/ "$mask")"

install_pkgurl
