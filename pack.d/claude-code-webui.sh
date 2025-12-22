#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"

. $(dirname $0)/common.sh

PRODUCTDIR=opt/$PRODUCT
install -D -m755 $TAR $PRODUCTDIR/$PRODUCT || fatal

VERSION=$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar $PRODUCTDIR

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Networking/WWW
license: MIT
url: https://github.com/sugyan/claude-code-webui
summary: Web interface for Claude Code CLI
description: A modern web-based interface that transforms Claude CLI into an intuitive chat application.
EOF

return_tar $PKGNAME.tar
