#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

erc --here unpack "$TAR" || fatal

# Codex falls back to its regular shell backend; the bundled test zsh lacks
# modules and is incompatible with ALT Linux's libtinfo.
rm -r codex-resources/zsh || fatal

# The voice host with its bundled GStreamer/GLib libs is linked against glibc,
# unlike the static musl codex, so it is shipped only in codex-voice.
if [ "$PRODUCT" != "codex-voice" ] ; then
    rm -r codex-resources/voice || fatal
fi

# Keep the upstream package layout so Codex can find its bundled tools.
mkdir -p opt/codex
mv bin codex-package.json codex-path codex-resources opt/codex/ || fatal

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
