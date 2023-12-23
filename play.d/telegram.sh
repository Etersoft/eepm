#!/bin/sh

BASEPKGNAME=Telegram
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Telegram client from the official site"
PRODUCTALT="'' beta"
VERSION="$2"
TIPS="Run 'epm play telegram-desktop=beta' to install beta version of the Telegram client. Run 'epm play telegram-desktop version' to install the version of the Telegram client."

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    [ "$PKGNAME" = "$BASEPKGNAME" ] || VERSION="*beta"
    if ! is_glibc_enough 2.32 ; then
        VERSION="4.9.5"
    fi
fi


PKGURL=$(epm tool eget --list --latest https://github.com/telegramdesktop/tdesktop/releases "tsetup.$VERSION*.tar.xz") #"
[ -n "$PKGURL" ] || fatal "Can't get package URL"

epm --install pack $PKGNAME "$PKGURL"
