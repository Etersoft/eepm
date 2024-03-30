#!/bin/sh

PKGNAME=64Gram
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="64Gram (unofficial Telegram Desktop)"
URL="https://github.com/TDesktop-x64"
TIPS="Run 'epm play 64gram=<version>' to install the version of the 64Gram Telegram client."

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/TDesktop-x64/tdesktop/releases ${PKGNAME}_${VERSION}_linux.zip) || fatal "Can't get package URL"

epm --install pack $PKGNAME "$PKGURL"
