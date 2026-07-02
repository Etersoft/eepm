#!/bin/sh

PKGNAME=aeroadmin
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="AeroAdmin (remote desktop) from the official site, runs under Wine"
URL="https://www.aeroadmin.com/"

. $(dirname $0)/common.sh

if ! is_command wine ; then
    epm play wine || fatal
fi

# there is no native Linux build, only a single portable Windows .exe run under Wine
# the vendor keeps only the current build, older ones are not available
warn_version_is_not_supported

# last known version served by the rolling download link
VERSION="4.92"
PKGURL="https://ulm.aeroadmin.com/AeroAdmin.exe"

install_pack_pkgurl $VERSION
