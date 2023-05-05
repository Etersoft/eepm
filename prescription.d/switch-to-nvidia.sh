#!/bin/sh

[ "$1" != "--run" ] && echo "Switch to using nVidia proprietary driver" && exit

. $(dirname $0)/common.sh

assure_root
exit

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

if grep NVIDIA /proc/driver/nvidia/version 2>/dev/null ; then
    echo "Already installed."
    exit
fi

# ROSA: kroko-cli autoinstall
# https://www.altlinux.org/Nvidia#Смена_открытых_драйверов_на_проприетарные[1]

epm update || exit
epm update-kernel || exit

# TODO: проверить, совпадает ли ядро
# reboot now

# rewrite:
#rpm -e $(rpm -qf `modinfo -F filename nouveau`)
epm install --skip-installed nvidia_glx_common || exit
# FIXME: really needed,
# make-initrd

# Возьмём команды оттуда, потому что пакета может не быть
# epm assure /usr/bin/nvidia-install-driver nvidia_glx_common

epm update || exit
epm install --skip-installed apt-scripts-nvidia
a= apt-get install-nvidia || exit

a= x11presetdrv
a= ldconfig

echo "Done. Just you need reboot your system to use nVidia proprietary drivers."
