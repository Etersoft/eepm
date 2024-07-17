#!/bin/sh

PKGNAME=zwcad-viewer
SUPPORTEDARCHES="x86_64"
VERSION="2.1.5"
DESCRIPTION="ZWCAD Viewer from the official site"
URL="https://sapr-soft.ru/zwcad_viewer"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://sapr-soft.ru/download/Viewer/ZWCAD_Viewer_Beta.tar.gz"

install_pack_pkgurl $VERSION
