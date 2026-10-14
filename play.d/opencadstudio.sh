#!/bin/sh

PKGNAME=OpenCADStudio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Open CAD Studio: 2D/3D CAD with DWG/DXF support and GPU rendering"
URL="https://www.opencadstudio.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url https://github.com/HakanSeven12/OpenCADStudio 'OpenCADStudio-v*-linux-x86_64.AppImage')"
else
    PKGURL="https://github.com/HakanSeven12/OpenCADStudio/releases/download/v$VERSION/OpenCADStudio-v$VERSION-linux-x86_64.AppImage"
fi

install_pkgurl
