#!/bin/sh

PKGNAME=Joplin
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Joplin - an open source note taking and to-do application with synchronisation capabilities"
URL="https://joplinapp.org/"

. $(dirname $0)/common.sh

PKGURL="$(eget --list --latest https://github.com/laurent22/joplin/releases/ "Joplin-$VERSION.AppImage")"

install_pkgurl
