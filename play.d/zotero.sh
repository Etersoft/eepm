#!/bin/sh

PKGNAME=zotero
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="A free, easy-to-use tool to help you collect, organize, cite, and share your research sources."
URL="https://github.com/zotero/zotero"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

case "$arch" in
    aarch64)
        arch="arm64"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag "$URL")
fi

PKGURL="https://www.zotero.org/download/client/dl?channel=release&platform=linux-$arch&version=$VERSION"

install_pack_pkgurl
