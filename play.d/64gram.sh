#!/bin/sh

PKGNAME=64Gram
SUPPORTEDARCHES="x86_64"
DESCRIPTION="64Gram (unofficial Telegram Desktop)"
TIPS="Run 'epm play 64gram=<version>' to install the version of the 64Gram Telegram client."

BRANCH="[0-9]"
VERSION=".*$BRANCH"
[ -n "$2" ] && [ "$2" != "beta" ] && VERSION="$2"

. $(dirname $0)/common.sh


PKGURL=$(epm tool eget --list --latest https://github.com/TDesktop-x64/tdesktop/releases "${PKGNAME}_${VERSION}_linux.zip") #"
[ -n "$PKGURL" ] || fatal "Can't get package URL"

epm --install pack $PKGNAME "$PKGURL"
