#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

# Use npm only as a data archive; no npm install or Node.js launcher.
erc --here unpack "$TAR" || fatal
case "$(epm print info -a)" in
    x86_64) arch=x64 ;;
    aarch64) arch=arm64 ;;
    *) fatal "Unsupported architecture" ;;
esac
mkdir -p "opt/$PRODUCT/bin" usr/bin || fatal
install -m755 "package/bin/$PRODUCT-linux-$arch" "opt/$PRODUCT/bin/$PRODUCT" || fatal
# The native CLI resolves these directories relative to its executable.
cp -a package/skills package/skill-data "opt/$PRODUCT/" || fatal
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
