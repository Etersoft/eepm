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
    # Upstream now publishes a full build id like
    # 2026.06.24-00-45-58-9f61de7 and composes DOWNLOAD_URL from OS/ARCH
    # variables inside the installer script, so extract the build id first.
    VERSION="$(printf '%s\n' "$install_script" | grep -oE '[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[a-f0-9]+' | head -n1)"
    [ -n "$VERSION" ] || fatal "Can't get latest version from Cursor installer"
    PKGURL="https://downloads.cursor.com/lab/$VERSION/linux/$arch/agent-cli-package.tar.gz"
else
    PKGURL="https://downloads.cursor.com/lab/$VERSION/linux/$arch/agent-cli-package.tar.gz"
fi

[ -n "$PKGURL" ] || fatal "Can't get package URL from Cursor installer"

install_pack_pkgurl
