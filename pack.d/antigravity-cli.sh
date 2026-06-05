#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || fatal "Can't pack without version"

mkdir -p usr/bin

erc --here unpack $TAR || fatal

mv antigravity usr/bin/agy

chmod 755 usr/bin/agy

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Development/Tools
license: Proprietary
url: https://antigravity.google/
summary: Google's agentic development platform (CLI companion)
description: The official Antigravity CLI - an AI coding agent for the terminal.
EOF

return_tar $PKGNAME.tar
