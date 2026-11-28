#!/bin/sh

PKGNAME=credo-3dviewer
VERSION="$2"
SUPPORTEDARCHES="x86_64"
DESCRIPTION="TIM CREDO 3D VIEWER (free point cloud viewer) from the official site"
URL="https://credo-dialogue.ru/produkty/tim-kredo-3d-vyuver.html"

. $(dirname $0)/common.sh

# upstream package is named credo-viewer and installed into /opt/credo-viewer (conflicts with TIM CREDO VIEWER),
# so repack.d/credo-3dviewer.sh renames and relocates it
export EPM_REPACK_SCRIPT=$PKGNAME

# the file name version (2024.1-1) differs from the package version (2024.1.1.8)
warn_version_is_not_supported

PKGURL="$(eget --list --latest https://credo-dialogue.ru/tsentr-zagruzki/programmy-dla-skachivania.html "credo-3Dviewer-*.x86_64.rpm")"

install_pkgurl
