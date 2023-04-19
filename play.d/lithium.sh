#!/bin/sh

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
DESCRIPTION="CAD of printed circuit boards"

. $(dirname $0)/common.sh


case $pkgtype in
    rpm)
        mask="$PKGNAME-*.x86_64.rpm"
        ;;
    *)
        mask="$PKGNAME_*_amd64.deb"
        ;;
esac

repack=''
case $(epm print info -s) in
    alt)
        repack="--repack"
esac

# https://www.lecad.ru/?download=&kcccount=https://www.lecad.ru/wp-content/uploads/lithium-ecad_1.7.5_amd64.deb
# https://www.lecad.ru/?download=&kcccount=https://www.lecad.ru/wp-content/uploads/lithium_ecad-1.7.5-0.x86_64.rpm
PKGURL="$(eget --list --latest https://www.lecad.ru/actual-version/ "$mask")"

epm $repack install "$PKGURL"
