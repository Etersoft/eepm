#!/bin/sh

PKGNAME=faststone-image-viewer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='An image browser, converter and editor that supports all major graphic formats.'
URL="https://www.faststone.org/FSViewerDetail.htm"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION=$(eget -q -O- "https://www.faststone.org/FSViewerDetail.htm" | grep -o -m 1 "Version [0-9.]\+" | awk '{print $2}')

PKGURL="https://www.faststonesoft.net/DN/FSViewer${VERSION//./}.zip"

install_pack_pkgurl $VERSION


