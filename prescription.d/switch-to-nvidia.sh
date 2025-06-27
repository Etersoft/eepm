#!/bin/sh

# ROSA: kroko-cli autoinstall
# https://www.altlinux.org/Nvidia#Смена_открытых_драйверов_на_проприетарные[1]
# https://www.altlinux.org/Переход_на_драйверы_Nvidia_и_fglrx#Установка_проприетарных_драйверов_nvidia_и_fglrx_:

SUPPORTEDARCHES=''
DESCRIPTION="Switch to using Nvidia proprietary driver"

. $(dirname $0)/common.sh

assure_root

if [ "$(epm print info -s)" = "rosa" ] ; then
    epm assure kroko-cli auto-krokodil-cli || fatal
    a='' kroko-cli autoinstall
    exit
fi

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux and ROSA Linux are supported"

epm assure lspci pciutils || exit
# проверяем работоспособность драйвера на текущий момент
nvidia_installed=false
if [ -z "$force" ] && a= lspci -k | grep -A 2 -i "VGA" | grep "Kernel driver in use" | grep -q "nvidia"; then
    echo "Nvidia driver is already installed and used."
    nvidia_installed=true
fi

# Установка драйвера (если нужен)
if [ "$nvidia_installed" = false ] || [ -n "$force" ]; then
    epm update || fatal
    epm update-kernel || fatal

    if ! epm update-kernel --check-run-kernel ; then
        echo "Please reboot the system to run the latest kernel."
        fatal
    fi

    epm install --skip-installed nvidia_glx_common || fatal

    apt_auto=''
    [ -n "$auto" ] && apt_auto='-y'
    # используем команды из nvidia-install-driver
    # устанавливает проприетарные драйвера nvidia и модули для ядра
    a= apt-get $apt_auto install-nvidia || fatal
    a= x11presetdrv # сканирует PCI в /sys на предмет видеоплат производителя NVIDIA. Если таковые найдены, ищет пары драйверов ядерный+X-овый, совпадающие по версии. Переключает /lib/modules/`uname -r`/nVidia/nvidia.ko на выбранную версию
    a= ldconfig # обновляет кэш информации о новейших версиях разделяемых библиотек

    # Отключаем nouveau и nova
    cat > /etc/modprobe.d/blacklist-nvidia-x11.conf <<'EOF'
blacklist nouveau
blacklist nova_core
blacklist nova_drm
EOF

    if [ -e "/etc/X11/xorg.conf" ] && grep -Eq 'nouveau|fbdev|vesa' "/etc/X11/xorg.conf"; then
        rm -v "/etc/X11/xorg.conf"
    fi

    # Чистим xorg конфиг и блеклисты от switch-to-nouveau
    for file in /etc/modprobe.d/blacklist-nouveau-x11.conf /etc/X11/xorg.conf.d/10-monitor.conf; do
        [ -f "$file" ] && rm -f "$file"
    done

    epm install --skip-installed nvidia-settings nvidia-vaapi-driver ocl-nvidia libcuda vulkan-tools libnvidia-encode libnvidia-ngx libnvidia-opencl libvulkan1 nvidia-modprobe \
        nvidia-xconfig libvulkan1 libcudadebugger libnvcuvid libnvidia-api \
        libnvidia-fbc libnvidia-ml libnvidia-nvvm libnvidia-ptxjitcompiler libnvoptix nvidia-smi libxnvctrl0

    epm prescription i586-fix
fi

check_old_nvidia () {
    local lspci_output=$(a= lspci -k 2>/dev/null | grep -E 'VGA|3D' | tr -d '\n')
    # Fermi, Kepler and Tesla
    [[ "$lspci_output" == *GF[0-9]* ]] || [[ "$lspci_output" == *GK[0-9]* ]] || [[ "$lspci_output" == *G[0-9]* ]] || [[ "$lspci_output" == *GT[0-9]* ]] || [[ "$lspci_output" == *MCP[0-9]* ]]
}

# Параметры ядра:
# - initcall_blacklist=simpledrm_platform_driver_init: отключает simpledrm для старых карт (Убирает «Неизвестный монитор» в настройках дисплеев)
# - nvidia_drm.fbdev=1: включает поддержку fbdev
# - nvidia_drm.modeset=1: включает KMS для Wayland и DRM
# - nvidia.NVreg_EnableGpuFirmware=0: отключает GSP (GPU System Processor, может вызывать проблемы на проприетарных драйверах, а на nvidia-open этот параметр ничего не делает)
if check_old_nvidia ; then
	# Данное решение приводит к невозможности входа в tty, к отсутствию вывода логов во время загрузки, а так же к поломке luks
    epm update-kernel --add-kernel-options initcall_blacklist=simpledrm_platform_driver_init
else
	# Вроде по умолчанию с 570 драйверов, но на всякий случай оставлю здесь
    epm update-kernel --add-kernel-options nvidia_drm.fbdev=1
fi
epm update-kernel --add-kernel-options nvidia_drm.modeset=1
epm update-kernel --add-kernel-options nvidia.NVreg_EnableGpuFirmware=0

# Включаем systemd-сервисы управления питанием NVIDIA
# Без этих служб могут не работать suspend/resume (сон/гибернация)
a= systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service

echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp" > /etc/modprobe.d/nvidia_memory_allocation.conf

# https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-utils/-/issues/2
# https://bugzilla.altlinux.org/53339
cat > /etc/udev/rules.d/99-nvidia.rules <<'EOF'
# Automatically create NVIDIA device nodes if missing (Wayland, EGLStream, compute)
ACTION=="bind", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", DRIVER=="nvidia", \
    RUN+="/usr/bin/nvidia-modprobe", \
    RUN+="/usr/bin/nvidia-modprobe -c0 -u"
EOF
echo "nvidia-uvm" > /etc/modules-load.d/nvidia-uvm.conf

# Перезапуск udev и обновление initrd/grub
a= udevadm control --reload
a= udevadm trigger
a= make-initrd
a= update-grub


echo "Done. Just you need reboot your system to use nVidia proprietary drivers."
