#!/bin/sh

PKGNAME=Telegram
DESCRIPTION="Telegram client from the official site"

if [ "$1" = "--remove" ] ; then
    # $PKGNAME-stable really
    epm remove $(epmqp $PKGNAME)
    exit
fi

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

PKGURL=$(epm tool eget --list --latest https://github.com/telegramdesktop/tdesktop/releases "tsetup.*.tar.xz") #"
[ -n "$PKGURL" ] || fatal "Can't get package URL"
PKGFILE=$(echo /tmp/$(basename $PKGURL) | sed -e "s|/tsetup|/$PKGNAME|")
epm tool eget -O $PKGFILE $PKGURL || exit

epm install --repack "$PKGFILE" || exit

rm -fv $PKGFILE
