#!/bin/sh

PKGNAME=agent-browser
SUPPORTEDARCHES="x86_64 aarch64" # any
VERSION="$2"
DESCRIPTION="Browser automation CLI for AI agents"
URL="https://github.com/vercel-labs/agent-browser"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- "https://registry.npmjs.org/$PKGNAME/latest" | parse_json_value '["version"]')
fi
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGURL="https://registry.npmjs.org/$PKGNAME/-/$PKGNAME-$VERSION.tgz"
install_pack_pkgurl
