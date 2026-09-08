#!/bin/sh

PKGNAME=QuickADB
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="QuickADB - graphical interface for automating ADB and fastboot commands"
URL="https://github.com/codefl0w/QuickADB"

. $(dirname $0)/common.sh

case "$(epm print info -a)" in
    x86_64)
        arch=x86_64
        ;;
    aarch64)
        arch=arm64
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag "$URL")"
    [ -n "$VERSION" ] || fatal "Can't get version from GitHub"
fi

PKGURL="$URL/releases/download/V$VERSION/QuickADB_V${VERSION}_Linux_${arch}.AppImage"

install_pkgurl
