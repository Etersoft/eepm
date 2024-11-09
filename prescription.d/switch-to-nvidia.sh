#!/usr/bin/env bash

# ROSA: kroko-cli autoinstall
# https://www.altlinux.org/Nvidia#Смена_открытых_драйверов_на_проприетарные[1]
# https://www.altlinux.org/Переход_на_драйверы_Nvidia_и_fglrx#Установка_проприетарных_драйверов_nvidia_и_fglrx_:

[ "$1" != "--run" ] && echo "Switch to using Nvidia proprietary driver" && exit

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
if [ -z "$force" ] && a= lspci -k | grep -A 2 -i "VGA" | grep "Kernel driver in use" | grep -q "nvidia" ; then
	echo "Nvidia driver is already installed and used."
	exit
fi

# epm full-upgrade does too many things for this spec
epm update || fatal
# epm upgrade || fatal
epm update-kernel || fatal

check_old_nvidia () {
	local lspci_output=$(a= lspci -k 2>/dev/null | grep -E 'VGA|3D' | tr -d '\n')
	# Fermi, Kepler and Tesla
	[[ "$lspci_output" == *GF[0-9]* ]] || [[ "$lspci_output" == *GK[0-9]* ]] || [[ "$lspci_output" == *G[0-9]* ]] || [[ "$lspci_output" == *GT[0-9]* ]] || [[ "$lspci_output" == *MCP[0-9]* ]] && return 0
    return 1
}

if ! epm update-kernel --check-run-kernel ; then
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

# отключаем nouveau
echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nvidia-x11.conf
a= modprobe -r nouveau

# удаляем /etc/X11/xorg.conf если он есть и в нём содержится nouveau или fbdev
if [ -e "/etc/X11/xorg.conf" ] && [ "$(grep -E 'nouveau|fbdev|vesa' "/etc/X11/xorg.conf")"  ] ; then
	 rm -v "/etc/X11/xorg.conf"
fi

epm install --skip-installed nvidia-settings nvidia-vaapi-driver ocl-nvidia libcuda vulkan-tools libnvidia-encode libnvidia-ngx libnvidia-opencl libvulkan1 nvidia-modprobe \
	nvidia-xconfig libvulkan1 libcudadebugger libnvcuvid libnvidia-api \
	libnvidia-fbc libnvidia-ml libnvidia-nvvm libnvidia-ptxjitcompiler libnvoptix nvidia-smi libxnvctrl0

epm prescription i586-fix

# Убирает «Неизвестный монитор» в настройках дисплеев
if check_old_nvidia ; then
	# Данное решение приводит к невозможности входа в tty, к отсутствию вывода логов во время загрузки, а так же к поломке luks
	epm update-kernel --add-kernel-options initcall_blacklist=simpledrm_platform_driver_init
else
	epm update-kernel --add-kernel-options nvidia_drm.fbdev=1
fi

# Активируем службы управления питания NVIDIA, без этих служб будет некоректно работать уход в сон
a= systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp" > /etc/modprobe.d/nvidia_memory_allocation.conf

# Запускаем регенерацию initrd
a= make-initrd

# Обновляем grub
a= update-grub

echo "Done. Just you need reboot your system to use nVidia proprietary drivers."
