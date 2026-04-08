#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION=$3

. $(dirname $0)/common.sh

# radicle-x86_64-unknown-linux-musl.tar.gz
BASENAME=$(basename $TAR .tar.gz)

erc --here unpack $TAR || fatal
cd "$(erc basename "$TAR")" || fatal

mkdir -p usr/share/man/man1
mkdir -p opt/$PRODUCT

mv man/man1/*.1 usr/share/man/man1/
mv bin/* opt/$PRODUCT/

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://radicle.xyz/
summary: Radicle HTTP daemon for web access to Radicle repositories
description: Radicle HTTP daemon for web access to Radicle repositories.
EOF

return_tar $PKGNAME.tar
