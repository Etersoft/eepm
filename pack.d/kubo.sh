#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc --here unpack $TAR && cd kubo || fatal
install -m755 -D ipfs usr/bin/ipfs
rm -v ipfs install.sh README.md
mkdir -p usr/share/doc/$PRODUCT
mv LICENSE* usr/share/doc/$PRODUCT

# kubo_v0.41.0-rc1_linux-amd64.tar.gz -> 0.41.0-rc1
FULL_VERSION="$(echo "$TAR" | sed -e 's|.*kubo_v||' -e 's|_.*||')"
# split: VERSION before first dash, RC_PART after (e.g. rc1)
VERSION="$(echo "$FULL_VERSION" | sed -e 's|-.*||')"
RC_PART="$(echo "$FULL_VERSION" | sed -n 's|^[^-]*-||p')"
PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
release: ${RC_PART:-1}
group: File tools
license: MIT/Apache-2.0
url: https://github.com/ipfs/kubo
summary: An IPFS implementation in Go
description: An IPFS implementation in Go.
EOF

return_tar $PKGNAME.tar
