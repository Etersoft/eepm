#!/bin/sh

PKGNAME=f3d
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Fast and minimalist 3D viewer (with raytracing support)"
URL="https://f3d.app"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/f3d-app/f3d" "F3D-*-Linux-x86_64-raytracing.deb")
else
    PKGURL="https://github.com/f3d-app/f3d/releases/download/v${VERSION}/F3D-${VERSION}-Linux-x86_64-raytracing.deb"
fi

install_pkgurl
