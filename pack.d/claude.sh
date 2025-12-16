#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PRODUCTDIR=opt/claude.ai
install -D -m755 $TAR $PRODUCTDIR/claude || fatal

[ -n "$VERSION" ] || fatal "can't pack with empty VERSION"

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar $PRODUCTDIR

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Networking/Instant messaging
license: Proprietary
url: https://claude.ai/
summary: Claude is a next generation AI assistant
description: Claude is a next generation AI assistant built by Anthropic
EOF

return_tar $PKGNAME.tar
