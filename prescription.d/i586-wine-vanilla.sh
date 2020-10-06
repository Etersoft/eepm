#!/bin/sh

MAIN=wine-vanilla

[ "$1" != "--run" ] && echo "Install 32 bit $MAIN packages on 64 bit system" && exit

[ "$(distro_info -d)" != "ALTLinux" ] && echo "Only ALTLinux is supported" && exit 1
[ "$(distro_info -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# Устанавливаем wine
epmi lib$MAIN i586-$MAIN i586-lib$MAIN i586-lib$MAIN-gl

# Доставляем пропущенные модули (подпакеты) для установленных 64-битных
epm prescription i586-fix
