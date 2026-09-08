#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

erc -C "opt/$PRODUCT" unpack "$TAR" || fatal

PKGNAME="$PRODUCT-$VERSION"
cat <<EOF >"$PKGNAME.tar.eepm.yaml"
name: $PRODUCT
group: Development/Tools
license: MIT
url: https://github.com/steipete/CodexBar
summary: Usage and status CLI for OpenAI Codex and Claude Code
description: Shows local usage statistics for OpenAI Codex and Claude Code without a separate login.
EOF

erc pack "$PKGNAME.tar" opt || fatal
return_tar "$PKGNAME.tar"
