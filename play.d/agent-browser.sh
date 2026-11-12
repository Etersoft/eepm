#!/bin/sh

PKGNAME=agent-browser
SUPPORTEDARCHES="x86_64 aarch64" # any
VERSION="$2"
DESCRIPTION="Browser automation CLI for AI agents"
URL="https://github.com/vercel-labs/agent-browser"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag "$URL")
    VERSION=${VERSION#v}
fi
[ -n "$VERSION" ] || fatal "Can't get package version"

case "$(epm print info -a)" in
    x86_64) arch=x64 ;;
    aarch64) arch=arm64 ;;
    *) fatal "Unsupported architecture" ;;
esac

PKGURL="$URL/releases/download/v$VERSION/agent-browser-linux-$arch"
install_pack_pkgurl "$VERSION"
