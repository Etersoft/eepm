#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

PKGNAME="$(basename $TAR .run | tr "[A-Z_]" "[a-z-]")"

install -D $TAR opt/$PRODUCT/$PRODUCT || fatal
erc pack $PKGNAME.tar opt/$PRODUCT

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Graphics
license: GPLv2
url: https://cuda-z.sourceforge.net/
summary: CUDA-Z
description: CUDA-Z.
EOF

return_tar $PKGNAME.tar
