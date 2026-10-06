#!/bin/sh

PKGNAME=xnview
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="XnView MP: Image management from the official site"
URL="https://xnview.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://download.xnview.com/XnViewMP-linux-x64.deb"

# XnView MP 1.12.0+ is built with Qt 6 for x86-64-v2 (requires sse4.1 sse4.2 popcnt)
# use the last Qt 5 based build on older CPUs (Core 2 etc.)
if ! grep -qw sse4_2 /proc/cpuinfo || ! grep -qw popcnt /proc/cpuinfo ; then
    info 'Your CPU does not support x86-64-v2 (sse4.2, popcnt), installing XnView MP 1.11.7 (the last version built with Qt 5)'
    PKGURL="https://download.xnview.com/old_versions/XnView_MP/XnView_MP-1.11.7-linux-x64.deb"
fi

install_pkgurl
