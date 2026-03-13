#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]{4}\.[0-9]{2}\.[0-9]+-[a-f0-9]+' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

PRODUCTDIR=opt/$PRODUCT

mkdir -p $PRODUCTDIR
erc -C $PRODUCTDIR unpack "$TAR" || fatal
# tar has dist-package/ as top-level directory
if [ -d $PRODUCTDIR/dist-package ] ; then
    mv $PRODUCTDIR/dist-package/* $PRODUCTDIR/ || fatal
    rmdir $PRODUCTDIR/dist-package
fi

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar $PRODUCTDIR

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Development/Tools
license: Proprietary
url: https://www.cursor.com/cli
summary: Cursor Agent CLI
description: Cursor Agent CLI - AI coding agent from Cursor
EOF

return_tar $PKGNAME.tar
