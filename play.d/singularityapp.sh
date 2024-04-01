#!/bin/sh

PKGNAME=singularityapp
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SingularityApp from the official site"
URL="https://snapcraft.io/singularityapp"

. $(dirname $0)/common.sh

PKGURL="$(snap_get_pkgurl $PKGNAME)"
install_pkgurl
