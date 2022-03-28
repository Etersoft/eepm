#!/bin/sh

MAIN=wine
[ -n "$2" ] && MAIN="$2"

distro="$($DISTRVENDOR -d)" ; [ "$distro" = "ALTLinux" ] || [ "$distro" = "ALTServer" ] || { echo "Only ALTLinux is supported" ; exit 1 ; }

arch="$($DISTRVENDOR -a)"

PKGCOMMON="wine-mono wine-gecko winetricks"

if [ "$1" = "--remove" ] ; then
    epm remove $(epmqp $MAIN-)
    epm remove $PKGCOMMON
    exit
fi

[ "$1" != "--run" ] && echo "Install $MAIN packages" && exit

# do some magic: if winetricks more than 20210206, we have new wine package naming
epm install winetricks || exit 1
WTVER="$(epm print version for package winetricks)"
if [ "$(epm print compare package version "$WTVER" "20210206")" = "1" ] ; then
    PKGNAMES="$MAIN-full $MAIN-twain $PKGCOMMON"
    PKGNAMES32="i586-$MAIN i586-$MAIN-gl i586-$MAIN-twain"
else
    # old naming scheme
    PKGNAMES="$MAIN lib$MAIN lib$MAIN-gl lib$MAIN-twain $PKGCOMMON"
    PKGNAMES32=''
    echo "We recommend ask about more new wine from your vendor."
fi

case $arch in
    x86_64)
        PKGNAMES="$PKGNAMES $PKGNAMES32"
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
