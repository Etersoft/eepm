#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(basename "$TAR" .tar.gz | sed -e 's|^vtcode-||' -e 's|-[a-z0-9_]*-unknown-linux-gnu$||')"
[ -n "$VERSION" ] || fatal "Can't get package version"

mkdir -p usr/bin usr/share || fatal
erc -C src unpack "$TAR" || fatal
mv src/vtcode usr/bin/ || fatal
mv src/man usr/share/ || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

cat <<EOF2 >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://github.com/vinhnx/VTCode
summary: VT Code - open-source Rust terminal coding agent
description: VT Code is an open-source Rust terminal coding agent.
EOF2

return_tar $PKGNAME.tar
