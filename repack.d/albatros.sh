#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
ORIGINPACKAGE="$4"

# upstream package name is albatros (internal project name)
PKGNAME=topomatic360
PRODUCT=topomatic360
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

subst "s|^Name:.*|Name: $PKGNAME|" $SPEC

# rpm Version lags behind the application version (rpm 1.4.4 in topomatic360-linux-x86_64-1.4.5.rpm)
VERSION="$(basename "$ORIGINPACKAGE" .rpm | sed -n -e 's|^topomatic360-linux-x86_64-\([0-9][0-9.]*\)$|\1|p')"
[ -n "$VERSION" ] && subst "s|^Version:.*|Version: $VERSION|" $SPEC

move_to_opt "/opt/Топоматик 360"
fix_desktop_file "\"/opt/Топоматик 360/$PRODUCT\"" "$PRODUCT"

add_bin_link_command

# for Ubuntu 24+ userns only, does not match the new path
remove_file $PRODUCTDIR/resources/apparmor-profile

add_electron_deps
