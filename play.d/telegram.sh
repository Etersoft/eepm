#!/bin/sh

PKGNAME=Telegram
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Telegram client from the official site"
PRODUCTALT="stable beta"
TIPS="Run 'epm play telegram-desktop=beta' to install beta version of the Telegram client. Run 'epm play telegram-desktop version' to install the version of the Telegram client."

BRANCH="[0-9]"
if echo "$2" | grep -q "beta" || epm installed Telegram-beta ; then
    BRANCH=beta
    PKGNAME=$PKGNAME-$BRANCH
fi

VERSION=".*$BRANCH"
[ -n "$2" ] && [ "$2" != "beta" ] && VERSION="$2"

. $(dirname $0)/common.sh


PKGURL=$(epm tool eget --list --latest https://github.com/telegramdesktop/tdesktop/releases "tsetup.$VERSION.tar.xz") #"
[ -n "$PKGURL" ] || fatal "Can't get package URL"
PKGDIR=$(mktemp -d)
trap "rm -fr $PKGDIR" EXIT
PKGFILE=$(echo $PKGDIR/$(basename $PKGURL) | sed -e "s|/tsetup|/$PKGNAME|")
epm tool eget -O $PKGFILE $PKGURL || exit

epm install --repack "$PKGFILE"
