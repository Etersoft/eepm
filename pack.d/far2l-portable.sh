#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
# PRODUCT="far2l"

. $(dirname $0)/common.sh

erc $TAR || fatal
pkg="$(ls | grep -e "far2l_[0-9].*_x86_64.*.AppImage")"
PKGNAME="${pkg/far2l/far2l-portable}"
mv $pkg $PKGNAME
return_tar "$PKGNAME"
