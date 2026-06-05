#!/bin/sh

PKGNAME=antigravity-cli
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Google's agentic development platform (CLI companion)"
URL="https://antigravity.google/product/antigravity-cli"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info --debian-arch)"
platform="linux_${arch}"

if ldd /bin/ls 2>&1 | grep -q musl ; then
    platform="${platform}_musl"
fi

PKG_MANIFEST_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/${platform}.json"

VERSION=$(get_json_value "$PKG_MANIFEST_URL" "version")
PKGURL=$(get_json_value "$PKG_MANIFEST_URL" "url")

[ -n "$PKGURL" ] || fatal "Can't get download URL from $PKG_MANIFEST_URL"

install_pack_pkgurl "$VERSION"
