#!/bin/sh

[ "$1" != "--run" ] && echo "Switch to using open source driver nouveau for NVIDIA cards" && exit

assure_root
exit

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

# https://www.altlinux.org/Nvidia#Смена_открытых_драйверов_на_проприетарные[1]

epm update || exit
epm update-kernel || exit
# epm full-upgrade || exit

# TODO: проверить, совпадает ли ядро
# reboot now

# TODO
#kernel-modules-drm-nouveau-std-def   (un-def)
#xorg-drv-nouveau
#xorg-dri-nouveau

echo "Set nouveau in /etc/X11/xorg.conf.d/10-monitor.conf"
a= xsetup-monitor -d nouveau

# TODO
grep nvidia /etc/X11/xorg.conf.d/*.conf /etc/X11/xorg.conf

#/etc/modprobe.d/blacklist-nvidia-x11.conf и записываем туда:[1]
#blacklist nvidia
#blacklist nouveau

# TODO
# rm -f /etc/modprobe.d/blacklist-alterator-x11
# или наоборот записываем в него вместо блокировки nouveau , блокировку nvidia

# TODO
a= x11presetdrv
a= ldconfig

# И не обязательно перезагружаться?
a= make-initrd -k $(uname -r)

# /usr/bin/nvidia-clean-driver

# TODO: https://www.altlinux.org/Nvidia#Замена_драйверов_nouveau/nvidia_"на_лету"

echo "Done. Just you need reboot your system to use open source nouveau drivers for NVIDIA cards."
