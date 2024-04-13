#!/bin/sh

PKGNAME=Joplin
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Joplin - an open source note taking and to-do application with synchronisation capabilities"
URL="https://joplinapp.org/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://joplinapp.org/help/install "Joplin-$VERSION.AppImage?source=JoplinWebsite&type=New")"
else
    PKGURL="https://objects.joplinusercontent.com/v$VERSION/Joplin-$VERSION.AppImage"
fi

#PKGURL="$(eget --list --latest https://github.com/laurent22/joplin/releases/ "Joplin-$VERSION.AppImage")"

install_pkgurl
