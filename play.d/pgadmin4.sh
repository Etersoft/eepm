#!/bin/sh

PKGNAME=pgadmin4
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="pgadmin4"

if [ "$1" = "--remove" ] ; then
    epm remove pgadmin4-server pgadmin4-desktop
    exit
fi

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] || VERSION="$VERSION-1"

BASEURL=https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/redhat/rhel-8Workstation-x86_64

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

pkgarch='x86_64'
epm $repack install $BASEURL/pgadmin4-server-$VERSION.el8.$pkgarch.rpm $BASEURL/pgadmin4-desktop-$VERSION.el8.$pkgarch.rpm
