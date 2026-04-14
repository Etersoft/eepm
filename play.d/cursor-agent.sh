#!/bin/sh

PKGNAME=cursor-agent
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Cursor Agent CLI - AI coding agent from Cursor"
URL="https://www.cursor.com/cli"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x64
        ;;
    aarch64)
        arch=arm64
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url https://cursor.com/install | grep -oE '[0-9]{4}\.[0-9]{2}\.[0-9]+-[a-f0-9]+' | head -1)"
    [ -n "$VERSION" ] || fatal "Can't get latest version"
fi

# URL uses - but rpm version stores ~ instead
URLVERSION="$(echo "$VERSION" | tr '~' '-')"
PKGURL="https://downloads.cursor.com/lab/$URLVERSION/linux/$arch/agent-cli-package.tar.gz"

install_pack_pkgurl
