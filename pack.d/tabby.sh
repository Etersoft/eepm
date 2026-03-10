#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"

. $(dirname $0)/common.sh

# Extract version from URL
# Example: https://github.com/TabbyML/tabby/releases/download/v0.32.0/tabby_x86_64-manylinux_2_28.tar.gz -> 0.32.0
VERSION="$(echo "$URL" | sed -n 's|.*/v\([0-9.]*\)/.*|\1|p')"
PKGNAME="$PRODUCT-$VERSION"

erc -C opt/$PRODUCT unpack $TAR || fatal

erc pack $PKGNAME.tar opt

cat <<YAML >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Development/Tools
license: Apache-2.0
url: https://github.com/TabbyML/tabby
summary: Self-hosted AI coding assistant
description: Self-hosted AI coding assistant
YAML

return_tar $PKGNAME.tar
