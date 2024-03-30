#!/bin/sh

PKGNAME=ipera-mediaserver
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="FlyView (Ipera) Server from the official site"

. $(dirname $0)/common.sh

warn_version_is_not_supported
#PKG="$(epm tool eget --list --latest https://flyviewvms.ru/downloads/ "flyview-server*linux64.deb")"
PKG="https://flyviewvms.ru/distro/flyview-server.deb"

epm install $PKG || exit

echo
echo "
Execute manually:
# groupadd -r ipera
# useradd -r -g ipera ipera
# chown ipera:ipera /var/lib/ipera
"

echo
echo "Note: run
# serv $PKGNAME on
to enable and start $PKGNAME system service
"
