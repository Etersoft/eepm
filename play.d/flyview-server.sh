#!/bin/sh

PKGNAME=ipera-mediaserver
SUPPORTEDARCHES="x86_64"
DESCRIPTION="FlyView (Ipera) Server from the official site"

. $(dirname $0)/common.sh

#PKG="$(epm tool eget --list --latest https://flyviewvms.ru/downloads/ "flyview-server*linux64.deb")"
PKG="https://flyviewvms.ru/distro/flyview-server.deb"

epm install $PKG || exit

# TODO:
# groupadd -r ipera
# useradd -r -g ipera ipera
# mkdir -p /opt/ipera/var
# chown ipera:ipera /opt/ipera/var

echo
echo "Note: run
# serv $PKGNAME on
to enable and start $PKGNAME system service
"
