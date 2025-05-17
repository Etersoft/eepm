#!/bin/sh

PKGNAME=singularityapp
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SingularityApp from the official site"
URL="https://snapcraft.io/singularityapp"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(snap_get_pkgurl $URL)"
install_pkgurl
