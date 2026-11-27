#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

mkdir -p opt/$PRODUCT

erc --here -C opt/$PRODUCT unpack "$TAR" || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Development/Tools
license: Proprietary
url: https://abacus.ai/help/abacusai-desktop/cli-installation
summary: Powerful CLI AI assistant
description: AbacusAI's powerful CLI AI assistant with agentic browsing, listening, and coding capabilities. Automate all your work with state of the art AI and the most powerful agent in the world.
EOF

return_tar $PKGNAME.tar
