#!/bin/sh

PKGNAME=openshot-qt
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="OpenShot Video Editor from the official site"
URL="https://github.com/OpenShot/openshot-qt"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/OpenShot/openshot-qt" "OpenShot-v${VERSION}-x86_64.AppImage")
else
    PKGURL="https://github.com/OpenShot/openshot-qt/releases/download/v${VERSION}/OpenShot-v${VERSION}-x86_64.AppImage"
fi

install_pack_pkgurl
