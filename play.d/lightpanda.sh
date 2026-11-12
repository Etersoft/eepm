#!/bin/sh

PKGNAME=lightpanda
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Fast headless browser for web automation and AI agents"
URL="https://lightpanda.io"

. $(dirname $0)/common.sh

case "$(epm print info -a)" in
    x86_64) arch=amd64 ;;
    aarch64) arch=arm64 ;;
    *) fatal "Unsupported architecture" ;;
esac

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag "https://github.com/lightpanda-io/browser")
fi

[ -n "$VERSION" ] || fatal "Can't get package version"
PKGURL="https://github.com/lightpanda-io/browser/releases/download/${VERSION}/lightpanda_${VERSION#v}_${arch}.deb"

install_pkgurl
