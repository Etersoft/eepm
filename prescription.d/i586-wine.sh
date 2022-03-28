#!/bin/sh

MAIN=wine

distro="$($DISTRVENDOR -d)" ; [ "$distro" = "ALTLinux" ] || [ "$distro" = "ALTServer" ] || { echo "Only ALTLinux is supported" ; exit 1 ; }
[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

PKGNAMES="lib$MAIN i586-$MAIN i586-lib$MAIN i586-lib$MAIN-gl"

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAMES
    exit
fi

[ "$1" != "--run" ] && echo "Install 32 bit $MAIN packages on 64 bit system" && exit

# Устанавливаем wine
epm install $PKGNAMES || exit

# Доставляем пропущенные модули (подпакеты) для установленных 64-битных
epm prescription i586-fix || exit

echo "See '# epm play wine' command to get best result."
