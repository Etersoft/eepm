#!/bin/sh

PKGNAME=tixati
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='It is a New and Powerful P2P System'
URL="https://tixati.com/"

. $(dirname $0)/common.sh

case "$(epm print info -p)" in
    rpm)
        mask="tixati-${VERSION}.x86_64.rpm"
        ;;
    *)
        mask="tixati_${VERSION}_amd64.deb"
        ;;
esac

PKGURL="$(eget --list --latest "https://download.tixati.com/" "$mask")"

install_pkgurl
