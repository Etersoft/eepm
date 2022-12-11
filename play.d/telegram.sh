#!/bin/sh

PKGNAME=Telegram
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Telegram client from the official site"

if [ "$1" = "--remove" ] ; then
    # $PKGNAME-stable really
    epm remove $(epmqp $PKGNAME)
    exit
fi

. $(dirname $0)/common.sh


PKGURL=$(epm tool eget --list --latest https://github.com/telegramdesktop/tdesktop/releases "tsetup.*.tar.xz") #"
[ -n "$PKGURL" ] || fatal "Can't get package URL"
PKGDIR=$(mktemp -d)
trap "rm -fr $PKGDIR" EXIT
PKGFILE=$(echo $PKGDIR/$(basename $PKGURL) | sed -e "s|/tsetup|/$PKGNAME|")
epm tool eget -O $PKGFILE $PKGURL || exit

epm install --repack "$PKGFILE"
