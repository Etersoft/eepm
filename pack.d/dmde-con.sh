#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
PKGURL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$PKGURL" | sed -n 's|.*/dmde-\([0-9][0-9-]*\)-lin[0-9][0-9]-con\.zip|\1|p' | sed 's|-|.|g')"
[ -n "$VERSION" ] || fatal "Can't get package version"
PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack "$TAR" || fatal
erc pack "$PKGNAME.tar" opt || fatal

cat <<EOF >"$PKGNAME.tar.eepm.yaml"
name: $PRODUCT
version: $VERSION
group: File tools
license: Proprietary
url: https://dmde.com/
summary: DMDE console data recovery tool
description: DMDE is a powerful tool for data searching, editing, and recovery on disks. It is able to recover directory structure and files even in some complex cases through the use of special algorithms when other software can't help.
EOF

return_tar "$PKGNAME.tar"
