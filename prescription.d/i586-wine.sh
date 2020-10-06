#!/bin/sh

MAIN=wine

[ "$1" != "--run" ] && echo "Install 32 bit $MAIN packages on 64 bit system" && exit

[ "$(distro_info -d)" != "ALTLinux" ] && echo "Only ALTLinux is supported" && exit 1

# Устанавливаем wine
epmi lib$MAIN i586-$MAIN i586-lib$MAIN i586-lib$MAIN-gl

# Модули, могут не быть в системе
epmi i586-glibc-nss i586-glibc-gconv-modules

# Если используется AD, потребуется
epm installed sssd-client && epmi i586-sssd-client
