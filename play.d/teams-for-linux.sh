#!/bin/sh

PKGNAME=teams-for-linux
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Unofficial Microsoft Teams for Linux client from the official site"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"

mask="teams-for-linux_${VERSION}_${arch}.deb"
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/IsmaelMartinez/teams-for-linux" "$mask")
else
    #https://github.com/IsmaelMartinez/teams-for-linux/releases/download/v2.0.14/teams-for-linux-2.0.14.x86_64.rpm
    #https://github.com/IsmaelMartinez/teams-for-linux/releases/download/v2.0.14/teams-for-linux-2.0.14.aarch64.rpm
    PKGURL="https://github.com/IsmaelMartinez/teams-for-linux/releases/download/v${VERSION}/$mask"
    #PKGURL="$ARCHIVEORG/$URL/$(epm print constructname $PKGNAME "$VERSION")"
fi

install_pkgurl
