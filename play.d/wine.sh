#!/bin/sh

PKGNAME=wine
SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION='Wine 32/64 from the repo'
TIPS="Run epm play wine=wine-vanilla to install wine-vanilla package"

MAIN=wine

vendor="$(epm print info -s)"
arch="$(epm print info -a)"

if [ "$vendor" != "alt" ] ; then
    # Устанавливаем wine
    epm install $PKGNAME || exit

    case $arch in
        x86_64)
            # Доставляем пропущенные модули (подпакеты) для установленных 64-битных
            epm prescription i586-fix
            ;;
        esac
    exit
fi

PKGCOMMON="wine-mono wine-gecko winetricks"

[ -n "$2" ] && MAIN="$2"

if [ "$MAIN" = "wine-etersoft" ] ; then
    PKGCOMMON="wine-etersoft-mono wine-etersoft-gecko wine-etersoft-winetricks"
    PKGNAMES="wine-etersoft"
    PKGNAMES32="wine32-etersoft"
fi

if [ "$1" = "--remove" ] ; then
    epm remove $(epmqp $MAIN-)
    epm remove $PKGCOMMON
    exit
fi

. $(dirname $0)/common.sh

ONLY32=''
[ "$2" == "--only-i586" ] && ONLY32=1 && shift
[ -n "$2" ] && MAIN="$2"

if [ "$MAIN" != "wine-etersoft" ] ; then

# do some magic: if winetricks more than 20210206, we have new wine package naming
epm install winetricks || exit 1
WTVER="$(epm print version for package winetricks)"
if [ "$(epm print compare package version "$WTVER" "20210206")" = "1" ] ; then
    PKGNAMES="$MAIN-full $MAIN-common"
    PKGNAMES32="i586-$MAIN"
else
    # old naming scheme
    PKGNAMES="$MAIN lib$MAIN lib$MAIN-gl lib$MAIN-twain"
    PKGNAMES32="i586-$MAIN i586-lib$MAIN i586-lib$MAIN-gl i586-lib$MAIN-twain"
    echo "We recommend ask about more new wine from your vendor."
fi

fi

case $arch in
    x86_64)
        PKGNAMES="$PKGNAMES $PKGNAMES32 $PKGCOMMON"
        [ -n "$ONLY32" ] && PKGNAMES="$PKGNAMES32 $PKGCOMMON"
        ;;
    x86)
        PKGNAMES="$PKGNAMES $PKGCOMMON"
        ;;
    *)
        echo "Arch $arch is not yet supported" && exit 1
esac


# Устанавливаем wine
epm install $PKGNAMES || exit

# TODO:
# epm policy $MAIN-gl 2>/dev/null >/dev/null || OLD wine packaging name scheme

case $arch in
    x86_64)
        # Доставляем пропущенные модули (подпакеты) для установленных 64-битных
        epm prescription i586-fix
        ;;
esac
