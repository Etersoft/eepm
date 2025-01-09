#!/bin/sh

PKGNAME=refind
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="An EFI boot manager utility"
URL="https://sourceforge.net/projects/refind"
TIPS="Run epm play refind=<version> to install some specific version"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- https://sourceforge.net/projects/refind/best_release.json | sed -e 's|.*refind-bin-\([^"]*\)\.zip.*|\1|')
fi

pkgtype="$(epm print info -p)"

case $pkgtype in
    deb)
        PKGURL="https://sourceforge.net/projects/refind/files/$VERSION/refind_$VERSION-1_amd64.deb/download"
        ;;
    *)
        PKGURL="https://sourceforge.net/projects/refind/files/$VERSION/refind-$VERSION-1.x86_64.rpm/download"
        ;;
esac

install_pkgurl
