#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

erc --here unpack "$TAR" || fatal

# Install everything under /opt/codex
mkdir -p opt/codex/bin opt/codex

mv bin/codex opt/codex/bin/codex || fatal
mv bin/codex-code-mode-host opt/codex/bin/codex-code-mode-host || fatal
chmod 755 opt/codex/bin/codex opt/codex/bin/codex-code-mode-host

mv codex-path opt/codex/path || fatal
mv codex-resources opt/codex/resources || fatal

# Symlinks for PATH
mkdir -p usr/bin
ln -s /opt/codex/bin/codex usr/bin/codex
ln -s /opt/codex/bin/codex-code-mode-host usr/bin/codex-code-mode-host

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr/bin || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://github.com/openai/codex
summary: Codex CLI
description: Codex CLI is a coding agent from OpenAI that runs locally on your computer.
EOF

return_tar $PKGNAME.tar
