#!/bin/sh

PKGNAME=aksusbd
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Sentinel LDK daemon (HASP) from the official site"

. $(dirname $0)/common.sh

# Dropping Support for HASP HL 1.x API and HASP4 API
# HASP HL 1.x API and HASP4 API are no longer supported with Sentinel LDK Run-time Environment RTE 8.41 or later.
PKGURL="https://sd7.ascon.ru/Public/Utils/Sentinel%20HASP/Linux_driver/aksusbd_vlib46707.tar"
epm pack --repack --install $PKGNAME $PKGURL
