#!/bin/sh

SUPPORTEDARCHES=''
DESCRIPTION="Switch to using open source driver nouveau for NVIDIA cards"

. "$(dirname "$0")/common.sh"

assure_root
[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

# make-initrd workers must be able to access the working directory (also over SSH).
cd / || fatal "Cannot access /"

for cmd in modinfo xsetup-monitor make-initrd update-grub; do
    is_command "$cmd" || fatal "Required command is missing: $cmd"
done

RUN_KERNEL="$(uname -r)" || fatal "Cannot determine the running kernel"

case "${3}" in
    '--clean' )
        rm -vf /etc/modprobe.d/blacklist-nouveau-x11.conf || fatal "Cannot remove NVIDIA blacklist"
        a= make-initrd -k "$RUN_KERNEL" || fatal "Cannot rebuild initramfs"
        a= update-grub || fatal "Cannot update GRUB configuration"
        exit 0
        ;;
    '' ) ;;
    * ) fatal "Unknown argument: ${3}" ;;
esac

epm update || fatal "Cannot update package lists"
epm update-kernel || fatal "Cannot update the kernel"
epm update-kernel --check-run-kernel || fatal "Reboot into the latest installed kernel and run this prescription again"

USED_KFLAVOUR="$(epm update-kernel --used-kflavour)" || fatal "Cannot determine the kernel flavour"
[ -n "$USED_KFLAVOUR" ] || fatal "Empty kernel flavour"
epm install --skip-installed "kernel-modules-drm-nouveau-$USED_KFLAVOUR" xorg-drv-nouveau || fatal "Cannot install nouveau drivers"

# Do not disable NVIDIA unless nouveau is available for the running kernel.
a= modinfo -k "$RUN_KERNEL" nouveau >/dev/null || fatal "No nouveau module for $RUN_KERNEL; configuration has not been switched"

echo "Set nouveau in /etc/X11/xorg.conf.d/10-monitor.conf"
a= xsetup-monitor -d nouveau || fatal "Cannot configure Xorg for nouveau"

# Clean files created by alterator, switch-to-nvidia and nvidia_glx_common.
for file in /etc/modprobe.d/blacklist-alterator-x11 /etc/modprobe.d/blacklist-nvidia-x11.conf \
            /etc/X11/xorg.conf.d/09-nvidia.conf /etc/modprobe.d/nvidia_memory_allocation.conf \
            /etc/udev/rules.d/99-nvidia.rules /etc/modules-load.d/nvidia-uvm.conf; do
    rm -f "$file" || fatal "Cannot remove $file"
done

epm update-kernel --remove-kernel-options initcall_blacklist=simpledrm_platform_driver_init \
    nvidia_drm.fbdev=1 nvidia.NVreg_EnableGpuFirmware=0 nvidia_drm.modeset=1 || fatal "Cannot remove NVIDIA kernel options"

# Keep the filename compatible with the cleanup in switch-to-nvidia.
cat > /etc/modprobe.d/blacklist-nouveau-x11.conf <<'EOF' || fatal "Cannot write NVIDIA blacklist"
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_uvm
blacklist nvidia_modeset
blacklist i2c_nvidia_gpu
EOF

a= make-initrd -k "$RUN_KERNEL" || fatal "Cannot rebuild initramfs; do not reboot until this is fixed"
a= update-grub || fatal "Cannot update GRUB configuration; do not reboot until this is fixed"

echo "Done. Reboot your system to use open source nouveau drivers for NVIDIA cards."
