#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

install -D $TAR usr/bin/ck-client || fatal
erc pack $PKGNAME.tar usr/bin

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking
license: GPL-3.0
url: https://github.com/cbeuw/Cloak
summary: Cloak client - censorship circumvention tool
description: A pluggable transport that enhances traditional proxy tools to evade deep packet inspection.
EOF

return_tar $PKGNAME.tar
