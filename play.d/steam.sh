#!/bin/sh

PKGNAME=steam-launcher
DESCRIPTION=''

. $(dirname $0)/common.sh

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

epm install "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
