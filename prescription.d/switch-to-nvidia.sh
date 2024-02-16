#!/usr/bin/env bash

# ROSA: kroko-cli autoinstall
# https://www.altlinux.org/Nvidia#Смена_открытых_драйверов_на_проприетарные[1]
# https://www.altlinux.org/Переход_на_драйверы_Nvidia_и_fglrx#Установка_проприетарных_драйверов_nvidia_и_fglrx_:

[ "$1" != "--run" ] && echo "Switch to using nVidia proprietary driver" && exit

. $(dirname $0)/common.sh

assure_root

if [ "$(epm print info -s)" = "rosa" ] ; then
    epm assure kroko-cli auto-krokodil-cli || fatal
    kroko-cli autoinstall
    exit
fi

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux and ROSA Linux are supported"

epm assure lspci pciutils || exit
# проверяем работоспособность драйвера на текущий момент
# TODO: добавить аргумент --force для принудительной переустановки
if a= lspci -k | grep -A 2 -i "VGA" | grep "Kernel driver in use" | grep -q "nvidia" ; then
	echo "NVIDIA driver is already installed."
	exit
fi

LSPCI_OUTPUT="$(lspci -k | grep VGA | tr -d '\n')"

if a= echo "$LSPCI_OUTPUT" | grep -qi "nvidia" | grep -qiE "(intel|amd)" ; then
	cat <<EOF > "/lib/udev/rules.d/80-nvidia-pm.rules"
# Remove NVIDIA USB xHCI Host Controller devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

# Remove NVIDIA USB Type-C UCSI devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

# Remove NVIDIA Audio devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

# Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
EOF

	cat <<EOF > "/etc/modprobe.d/nvidia-rtd3.conf"
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
options nvidia "NVreg_DynamicPowerManagement=0x02"
EOF
fi

# epm full-upgrade does too many things for this spec
epm update || fatal
# epm upgrade || fatal
epm update-kernel || fatal

# проверяем, совпадает ли ядро (пока нет такой проверки в update-kernel)
# TODO: добавить функцию в update-kernel и здесь использовать её
check_run_kernel () {
	USED_KFLAVOUR="$(uname -r | awk -F'-' '{print $(NF-2)}')-def"
	if [ -n "$(ls /boot | grep "vmlinuz" | grep -vE 'vmlinuz-un-def|vmlinuz-std-def' | grep "${USED_KFLAVOUR}" | sort -Vr | head -n1 | grep $(uname -r))" ] ; then
		echo "Запущено самое свежее установленное ${USED_KFLAVOUR} ядро."
		return 0
	else
		echo "В системе есть ${USED_KFLAVOUR} ядро свежее запущенного."
		echo "Перезагрузитесь со свежим ${USED_KFLAVOUR} ядром и перезапустите: epm play switch-to-nvidia"
		return 1
	fi
}

check_run_kernel || fatal

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
a= rmmod nouveau

# удаляем /etc/X11/xorg.conf если он есть и в нём содержится nouveau или fbdev
if [ -e "/etc/X11/xorg.conf" ] && [ "$(grep -E 'nouveau|fbdev|vesa' "/etc/X11/xorg.conf")"  ] ; then
	 rm -v "/etc/X11/xorg.conf"
fi


epm install --skip-installed nvidia-settings nvidia-vaapi-driver ocl-nvidia libcuda vulkan-tools libnvidia-encode libnvidia-ngx libnvidia-opencl libvulkan1 nvidia-modprobe \
	libglut libGLU nvidia-xconfig libvulkan1 libcudadebugger libnvcuvid libnvidia-api \
	libnvidia-fbc libnvidia-ml libnvidia-nvvm libnvidia-ptxjitcompiler libnvoptix nvidia-smi

epm play i586-fix

# Делаем копию
cp /etc/sysconfig/grub2 /etc/sysconfig/grub2.epmbak

# для работы 2-х и более видеокарт, а так же Wayland c nvidia необходимо добавить "nvidia-drm.modeset=1" в строку GRUB_CMDLINE_LINUX_DEFAULT= в файле /etc/default/grub и обновить grub
sed -i "s|^\(GRUB_CMDLINE_LINUX_DEFAULT='.*\)'\$|\1 nvidia-drm.modeset=1'|" /etc/sysconfig/grub2

# Убирает «Неизвестный монитор» в настройках дисплеев в сессии Wayland
sed -i "s|^\(GRUB_CMDLINE_LINUX_DEFAULT='.*\)'\$|\1 initcall_blacklist=simpledrm_platform_driver_init'|" /etc/sysconfig/grub2

# Запускаем регенерацию initrd
make-initrd

# Обновляем grub
update-grub

echo "Done. Just you need reboot your system to use nVidia proprietary drivers."
