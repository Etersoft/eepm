#!/bin/sh

PKGNAME=unreal-engine-stub
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unreal Engine stub (stub package with desktop, icon and mimetype"
URL="https://www.unrealengine.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION=0
PKGURL="ipfs://QmXWqBmLUjo9FDmJ5RsMUtEV1Z5ggTVQJWodyKTtrkPNuU?filename=$PKGNAME-$VERSION.tar"

install_pkgurl

cat <<EOF
Since Epic Games provides the Unreal Engine download link only to registered users, we cannot create a complete play script.

Since RPM 4 does not support package more than 4Gb size, we suggest you
download zip file manually from https://www.unrealengine.com/linux and
unpack Linux_Unreal_Engine**.zip to /opt/unreal-engine
EOF

