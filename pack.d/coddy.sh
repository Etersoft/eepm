#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

erc -C usr/bin unpack "$TAR" || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr/bin || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://github.com/coddy-project/coddy-agent
summary: Coddy Agent - a coding agent harness in one Go binary
description: A coding agent harness for software work. ReAct loop, filesystem and shell tools, MCP, project rules, skills, browser UI, scheduler, and long-term memory.
EOF

return_tar $PKGNAME.tar
