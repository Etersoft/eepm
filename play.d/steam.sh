#!/bin/sh

PKGNAME=steam-launcher
SUPPORTEDARCHES="x86_64"
DESCRIPTION=''

. $(dirname $0)/common.sh

epm install "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
