#!/bin/sh

PKGNAME=claude-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Claude Desktop native client from the official site'
URL="https://claude.ai/download"

. $(dirname $0)/common.sh

# Anthropic's official apt repository
REPO="https://downloads.claude.ai/claude-desktop/apt/stable"

# the .deb uses Debian arch names (amd64 / arm64)
debarch="$(epm print info --debian-arch)"

# The official repo rotates old .deb out of the pool and ships very often, so a
# version pinned in app-versions is usually already gone (404). Always resolve
# the current latest from the repo's Packages index instead of trusting VERSION.
VERSION="$(get_deb_repo_latest_version "$REPO/dists/stable/main/binary-$debarch/Packages.gz" claude-desktop)"

# pool/main/c/claude-desktop/claude-desktop_<version>_<arch>.deb
PKGURL="$REPO/pool/main/c/claude-desktop/claude-desktop_${VERSION}_${debarch}.deb"

install_pkgurl
