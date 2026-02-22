#!/bin/sh

PKGNAME=alt-sendme
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Frictionless, real-time file transfer tool"
URL=" https://github.com/tonyantony300/alt-sendme "

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

case $pkgtype in
    rpm)
        pkgformat="rpm"
        arch=$(epm print info -a)
        ;;
    *)
        pkgformat="deb"
        arch=$(epm print info --debian-arch)
        ;;
esac


PKGURL=$(get_github_url https://github.com/tonyantony300/alt-sendme "AltSendme-$VERSION.$arch.$pkgformat")

install_pkgurl
