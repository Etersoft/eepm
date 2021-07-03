#!/bin/sh -x

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=Telegram

if [ "$1" = "--remove" ] ; then
    # $PKGNAME-stable really
    epm remove $(epmqp $PKGNAME)
    exit
fi

[ "$1" != "--run" ] && echo "Install Telegram client from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

PKGURL=$($EGET --list --latest https://github.com/telegramdesktop/tdesktop/releases "tsetup.*.tar.xz") 
# hack: install latest know version if latest release have no binary for linux
# todo: check all releases?
STABLEVERSION=2.8.1
[ -n "$PKGURL" ] || PKGURL=https://github.com/telegramdesktop/tdesktop/releases/download/v$STABLEVERSION/tsetup.$STABLEVERSION.tar.xz
[ -n "$PKGURL" ] || fatal "Can't get package URL"
PKGFILE=$(echo /tmp/$(basename $PKGURL) | sed -e "s|/tsetup|/$PKGNAME|")
$EGET -O $PKGFILE $PKGURL || exit

epm install --repack "$PKGFILE" || exit

rm -fv $PKGFILE
