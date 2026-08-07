#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || fatal "Can't pack with empty VERSION"

install -D -m755 "$TAR" usr/bin/muse || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr/bin || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Development/Tools
license: Proprietary
url: https://dev.meta.ai/
summary: Muse Code - AI coding agent from Meta
description: Muse Code is an AI coding agent from Meta for software development in the terminal.
EOF

return_tar $PKGNAME.tar
