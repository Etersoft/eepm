#!/bin/sh

[ "$1" != "--run" ] && echo "Added snap support to system" && exit

. $(dirname $0)/common.sh

assure_root
exit

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

epm install snapd

a= systemctl enable --now snapd
a= ln -s /var/lib/snapd/snap /snap

echo "Done. Just you need reboot your system to use snaps"
