#!/bin/sh

PKGNAME=Simplenote-linux
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION='A Simplenote React client packaged in Electron.'
URL="https://github.com/Automattic/simplenote-electron"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -a)" in
    x86_64)
        arch="x86_64" ;;
    aarch64)
        arch="arm64" ;;
    armhf)
        arch="armv7l" ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/Automattic/simplenote-electron" "/$PKGNAME-.$VERSION-$arch.AppImage")
else
    PKGURL="https://github.com/Automattic/simplenote-electron/releases/download/v$VERSION/$PKGNAME-$VERSION-$arch.AppImage"
fi

install_pkgurl
