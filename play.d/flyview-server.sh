#!/bin/sh

PKGNAME=ipera-mediaserver
SUPPORTEDARCHES="x86_64"
DESCRIPTION="FlyView (Ipera) Server from the official site"

. $(dirname $0)/common.sh

PKG="$(epm tool eget --list --latest https://flyviewvms.ru/downloads/ "flyview-server*linux64.deb")"

epm install $PKG
