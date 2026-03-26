#!/bin/sh

PKGNAME=FreeCAD
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Free and open-source 3D parametric modeler from the official site"
URL="https://github.com/FreeCAD/FreeCAD"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    aarch64)
        ;;
    x86_64)
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

PKGURL=$(get_github_url "FreeCAD/FreeCAD" "FreeCAD_${VERSION}-Linux-${arch}-py311.AppImage")

install_pkgurl
