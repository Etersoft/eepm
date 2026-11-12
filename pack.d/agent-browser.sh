#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

# The release contains the binary; resources come from the matching source tag.
eget -O source.tar.gz "https://github.com/vercel-labs/agent-browser/archive/refs/tags/v$VERSION.tar.gz" || fatal "Can't download agent-browser sources"
erc --here unpack source.tar.gz || fatal
mkdir -p "opt/$PRODUCT/bin" usr/bin || fatal
install -m755 "$TAR" "opt/$PRODUCT/bin/$PRODUCT" || fatal
# The native CLI resolves these directories relative to its executable.
cp -a agent-browser-*/skills agent-browser-*/skill-data "opt/$PRODUCT/" || fatal
ln -s "/opt/$PRODUCT/bin/$PRODUCT" "usr/bin/$PRODUCT" || fatal

PKGNAME=$PRODUCT-$VERSION
erc pack "$PKGNAME.tar" opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://github.com/vercel-labs/agent-browser
summary: Browser automation CLI for AI agents
description: Browser automation CLI for AI agents.
EOF

return_tar "$PKGNAME.tar"
