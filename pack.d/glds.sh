#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKG="$(basename $TAR)"

# we need this pack script to override broken package version
cp -v $TAR $PKG

cat <<EOF >$PKG.eepm.yaml
name: $PRODUCT
version: $VERSION
upstream_file: $PKG
EOF

return_tar $PKG

