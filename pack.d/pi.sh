#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

mkdir -p usr/bin
mkdir -p opt/pi-linux

erc --here unpack "$TAR" || fatal

mv pi/* opt/pi-linux

chmod 755 "/opt/pi-linux/pi"

ln -s "/opt/pi-linux/pi" "usr/bin/pi"

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr opt || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: MIT
url: https://github.com/badlogic/pi-mono
summary: pi coding agent
description: Pi is a minimal terminal coding harness. Adapt pi to your workflows, not the other way around, without having to fork and modify pi internals.
# ALT ships the same upstream as pi-coding-agent; take over /usr/bin/pi cleanly
provides: pi-coding-agent
conflicts: pi-coding-agent
obsoletes: pi-coding-agent
EOF

return_tar $PKGNAME.tar
