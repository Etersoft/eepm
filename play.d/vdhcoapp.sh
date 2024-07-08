#!/bin/sh

PKGNAME=net.downloadhelper.coapp.noffmpeg
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Video DownloadHelper Companion App 2"
URL="https://www.downloadhelper.net/w/CoApp-Installation"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

mask="vdhcoapp-noffmpeg-linux-$arch.deb"
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/aclap-dev/vdhcoapp/" "$mask")
else
    PKGURL="https://github.com/aclap-dev/vdhcoapp/releases/download/v$VERSION/$mask"
fi

install_pkgurl
