#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

mkdir -p usr/bin
erc --here unpack "$TAR" || fatal
mv "$(basename "$TAR" .tar.gz)" usr/bin/codex || fatal
chmod 755 usr/bin/codex

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr/bin || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://github.com/openai/codex
summary: Codex CLI
description: Codex CLI is a coding agent from OpenAI that runs locally on your computer.
EOF

return_tar $PKGNAME.tar
