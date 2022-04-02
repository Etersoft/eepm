#!/bin/sh

MAIN=wine

vendor="$($DISTRVENDOR -s)" ; [ "$vendor" = "alt" ] || { echo "Only ALT distros is supported for now" ; exit 1 ; }
arch="$($DISTRVENDOR -a)"

PKGCOMMON="wine-mono wine-gecko winetricks"

if [ "$1" = "--remove" ] ; then
    epm remove $(epmqp $MAIN-)
    epm remove $PKGCOMMON
    exit
fi


[ "$1" != "--run" ] && echo "Install $MAIN packages (add wine-vanilla if you need these packages)" && exit

ONLY32=''
[ "$2" == "--only-i586" ] && ONLY32=1 && shift
[ -n "$2" ] && MAIN="$2"

# do some magic: if winetricks more than 20210206, we have new wine package naming
epm install winetricks || exit 1
WTVER="$(epm print version for package winetricks)"
if [ "$(epm print compare package version "$WTVER" "20210206")" = "1" ] ; then
    PKGNAMES="$MAIN-full $MAIN-twain"
    PKGNAMES32="i586-$MAIN i586-$MAIN-gl i586-$MAIN-twain"
else
    # old naming scheme
    PKGNAMES="$MAIN lib$MAIN lib$MAIN-gl lib$MAIN-twain"
    PKGNAMES32="i586-$MAIN i586-lib$MAIN i586-lib$MAIN-gl i586-lib$MAIN-twain"
    echo "We recommend ask about more new wine from your vendor."
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
