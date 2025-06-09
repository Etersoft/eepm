#!/bin/sh

PKGNAME=tixati
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='It is a New and Powerful P2P System'
URL="https://tixati.com/"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] || VERSION="$VERSION-1"

case "$(epm print info -p)" in
    rpm)
        mask="tixati-${VERSION}.x86_64.rpm"
        ;;
    *)
        mask="tixati_${VERSION}_amd64.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest "https://download.tixati.com/" "$mask")"
else
    PKGURL="https://download.tixati.com/$mask"
fi

install_pkgurl
