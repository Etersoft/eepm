#!/bin/sh

[ "$1" != "--run" ] && echo "Add snap support to system" && exit

CONFINEMENT="$2"

. $(dirname $0)/common.sh

assure_root

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux are supported"

epm install snapd

if epm installed plasma5-discover ; then
    epm install plasma5-discover-snap
fi

a= serv snapd on

if [ "$CONFINEMENT" = "classic" ] ; then
    # Симлинк нужен для работы класическиж snap пакетов
    a= ln -s /var/lib/snapd/snap /snap
fi

echo "Snap successfully installed, but epm play is the preferred way to install the software."
