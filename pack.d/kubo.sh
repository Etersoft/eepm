#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc unpack $TAR && cd kubo || fatal
install -m755 -D ipfs usr/bin/ipfs
rm -v ipfs install.sh README.md
mkdir -p usr/share/doc/$PRODUCT
mv LICENSE* usr/share/doc/$PRODUCT

VERSION="$(echo "$TAR" | sed -e 's|.*kubo_v||' -e 's|[-_].*||')"
PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: File tools
license: MIT/Apache-2.0
url: https://github.com/ipfs/kubo
summary: An IPFS implementation in Go
description: An IPFS implementation in Go.
EOF

return_tar $PKGNAME.tar
