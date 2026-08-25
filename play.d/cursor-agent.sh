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

install_script="$(fetch_url https://cursor.com/install)" || fatal "Can't fetch Cursor installer"

if [ "$VERSION" = "*" ] ; then
    VERSION="$(printf '%s\n' "$install_script" | sed -n 's|.*downloads.cursor.com/lab/\([^/][^/]*\)/.*|\1|p' | head -n1)"
    [ -n "$VERSION" ] || fatal "Can't get latest version from Cursor installer"
    PKGURL="https://downloads.cursor.com/lab/$VERSION/linux/$arch/agent-cli-package.tar.gz"
else
    PKGURL="https://downloads.cursor.com/lab/$VERSION/linux/$arch/agent-cli-package.tar.gz"
fi

[ -n "$PKGURL" ] || fatal "Can't get package URL from Cursor installer"

install_pack_pkgurl
