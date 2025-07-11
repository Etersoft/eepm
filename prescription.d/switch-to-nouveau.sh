#!/bin/sh

SUPPORTEDARCHES=''
DESCRIPTION="Switch to using open source driver nouveau for NVIDIA cards"

. $(dirname $0)/common.sh

case "${3}" in

    '--clean' )
        assure_root
        [ -f "/etc/modprobe.d/blacklist-nouveau-x11.conf" ] && rm -vf "/etc/modprobe.d/blacklist-nouveau-x11.conf"
        exit 0
        ;;
esac

assure_root
exit

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

# https://www.altlinux.org/Nvidia#Смена_открытых_драйверов_на_проприетарные[1]

epm update || fatal
epm update-kernel || fatal

if ! epm update-kernel --check-run-kernel ; then
    fatal
fi

USED_KFLAVOUR="$(epm update-kernel --used-kflavour)"
# TODO: fix to use just epmi kernel-modules-drm-nouveau
epm install --skip-installed kernel-modules-drm-nouveau-$USED_KFLAVOUR xorg-drv-nouveau i586-xorg-drv-nouveau || fatal

echo "Set nouveau in /etc/X11/xorg.conf.d/10-monitor.conf"
a= xsetup-monitor -d nouveau

# Clean alterator blacklist, epm files and nvidia_glx_common xorg config
for file in /etc/modprobe.d/blacklist-alterator-x11 /etc/modprobe.d/blacklist-nvidia-x11.conf /etc/X11/xorg.conf.d/09-nvidia.conf /etc/modprobe.d/nvidia_memory_allocation.conf /etc/udev/rules.d/99-nvidia.rules; do
    [ -f "$file" ] && rm -f "$file"
done

# Prevert nvidia for load
cat > /etc/modprobe.d/blacklist-nouveau-x11.conf <<'EOF'
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_uvm
blacklist nvidia_modeset
blacklist i2c_nvidia_gpu
EOF

a= make-initrd
a= update-grub

echo "Done. Just you need reboot your system to use open source nouveau drivers for NVIDIA cards."
