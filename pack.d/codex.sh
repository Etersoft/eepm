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
rm -rf codex-resources/zsh || fatal

# The voice host with its bundled GStreamer/GLib libs is linked against glibc,
# unlike the static musl codex, so it is shipped only in codex-voice.
if [ "$PRODUCT" != "codex-voice" ] ; then
    rm -rf codex-resources/voice || fatal
fi

# Keep the upstream package layout so Codex can find its bundled tools.
mkdir -p opt/codex
mv bin codex-package.json codex-path codex-resources opt/codex/ || fatal

# Symlinks for PATH
mkdir -p usr/bin
ln -s /opt/codex/bin/codex usr/bin/codex
ln -s /opt/codex/bin/codex-code-mode-host usr/bin/codex-code-mode-host

# System wide config (the lowest priority, users can override it in ~/.codex/config.toml).
# Do not auto start the app-server daemon: it copies the package to ~/.codex/packages
# and updates it there by itself, use the installed binaries instead.
mkdir -p etc/codex
cat <<EOF >etc/codex/config.toml
# Codex CLI system wide configuration (installed by epm play codex).
# Settings in ~/.codex/config.toml override these ones.
# Full reference: https://developers.openai.com/codex/config-reference
# Run 'codex features list' to see the effective features.

# Updates are managed by the package manager (epm play codex)
check_for_update_on_startup = false

# Disable usage analytics and feedback collection
#analytics.enabled = false
#feedback.enabled = false

# Web search tool mode: disabled, cached, indexed or live
#web_search = "cached"

# Do not write prompts history to ~/.codex/history.jsonl ("save-all" by default)
#history.persistence = "none"

[features]
# Do not start the background app-server daemon: it copies Codex
# to ~/.codex/packages and updates that copy by itself
daemon_auto_start = false
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr/bin etc || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://github.com/openai/codex
summary: Codex CLI
description: Codex CLI is a coding agent from OpenAI that runs locally on your computer.
EOF

return_tar $PKGNAME.tar
