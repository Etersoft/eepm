#!/bin/sh

PKGNAME=ipera-client
SUPPORTEDARCHES="x86_64"
DESCRIPTION="FlyView Client from the official site"

. $(dirname $0)/common.sh

PKG="$(epm tool eget --list --latest https://flyviewvms.ru/downloads/ "flyview-client*linux64.deb")"

epm install $PKG
