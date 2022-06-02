#!/bin/sh

PKGNAME=snap4arduino
DESCRIPTION="Snap4Arduino binds Snap! and Arduino together"

if [ "$1" = "--remove" ] ; then
    # $PKGNAME-stable really
    epm remove $(epmqp $PKGNAME)
    exit
fi

. $(dirname $0)/common.sh

arch=$($DISTRVENDOR --distro-arch)
case $arch in
    x86_64|amd64)
        arch=64 ;;
    i586)
        arch=32 ;;
    *)
        fatal "Unsupported arch $arch for $($DISTRVENDOR -d)"
esac

PKGURL=$(epm tool eget --list --latest https://github.com/bromagosa/Snap4Arduino/releases "Snap4Arduino_desktop-gnu-$arch_*.tar.gz") #"
[ -n "$PKGURL" ] || fatal "Can't get package URL"
PKGFILE=$(echo /tmp/$(basename $PKGURL) | sed -e "s|/Snap4Arduino_desktop-gnu-$arch\_|/$PKGNAME-|")
epm tool eget -O $PKGFILE $PKGURL || exit

epm install --repack "$PKGFILE" || exit

rm -fv $PKGFILE
