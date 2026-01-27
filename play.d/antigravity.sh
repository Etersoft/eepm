#!/bin/sh

PKGNAME=antigravity
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="An agentic development platform from Google, evolving the IDE into the agent-first era"
URL="https://antigravity.google"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info --debian-arch)"
PKG_INDEX_URL="https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/dists/antigravity-debian/main/binary-${arch}/Packages"

PKGVER="$(eget -O- "$PKG_INDEX_URL" \
    | grep '^Version:' \
    | tail -n1 \
    | cut -d' ' -f2)"

PKGMD5="$(eget -O- "$PKG_INDEX_URL" \
    | grep '^MD5sum:' \
    | tail -n1 \
    | cut -d' ' -f2)"

PKGURL="https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/pool/antigravity-debian/antigravity_${PKGVER}_${arch}_${PKGMD5}.deb"

install_pkgurl
