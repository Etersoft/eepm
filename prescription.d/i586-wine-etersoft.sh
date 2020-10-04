#!/bin/sh

MAIN=wine-etersoft

# Устанавливаем wine
epmi lib$MAIN i586-$MAIN i586-lib$MAIN i586-lib$MAIN-gl

# Модули, могут не быть в системе
epmi i586-glibc-nss i586-glibc-gconv-modules

# Если используется AD, потребуется
epm installed sssd-client && epmi i586-sssd-client
