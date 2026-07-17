#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

install -D -m755 $TAR usr/bin/grok || fatal

cat <<EOF | create_file /etc/grok/managed_config.toml
# Grok Build is updated by the system package manager.
[cli]
auto_update = false
EOF

[ -n "$VERSION" ] || fatal "can't pack with empty VERSION"

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr etc || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Development/Tools
license: Apache-2.0
url: https://x.ai/cli
summary: Grok Build CLI
description: Grok Build is a terminal-based AI coding agent from xAI.
EOF

return_tar $PKGNAME.tar
