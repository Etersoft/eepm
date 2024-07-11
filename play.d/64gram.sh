#!/bin/sh

PKGNAME=64Gram
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="64Gram (unofficial Telegram Desktop)"
URL="https://github.com/TDesktop-x64"
TIPS="Run 'epm play 64gram=<version>' to install the version of the 64Gram Telegram client."

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/TDesktop-x64/tdesktop/" "${PKGNAME}_.${VERSION}_linux.zip")
else
    PKGURL="https://github.com/TDesktop-x64/tdesktop/releases/download/v$VERSION/${PKGNAME}_${VERSION}_linux.zip"
fi

epm --install pack $PKGNAME "$PKGURL"
