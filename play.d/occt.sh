#!/bin/sh

PKGNAME=OCCT
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Free, all-in-one stability, stress test, benchmark and monitoring tool for PC"
URL="https://www.ocbase.com/download"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -q -O- https://www.ocbase.com/download | grep -oP '"versionStr":"\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n1)
    PKGURL="https://dl.ocbase.com/linux/per/stable/OCCT"
else
    PKGURL="https://www.ocbase.com/download/edition:Personal/os:Linux/version:$VERSION"
fi

install_pack_pkgurl "$VERSION"
