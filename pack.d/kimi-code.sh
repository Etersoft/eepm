#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

# the URL has a scoped, percent-encoded tag (...%40kimi-code%40VERSION/...),
# so strip everything up to the last %40 before matching the version
[ -n "$VERSION" ] || VERSION="$(echo "$URL" | sed -e 's|.*%40||' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

erc -C usr/bin unpack "$TAR" || fatal
# the binary comes from a zip; not every 7-zip backend keeps the exec bit
chmod 755 usr/bin/kimi || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr/bin || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: MIT
url: https://github.com/MoonshotAI/kimi-code
summary: Kimi Code CLI, the AI coding agent from Moonshot AI
description: Kimi Code is an AI coding agent for the terminal from Moonshot AI.
EOF

return_tar $PKGNAME.tar
