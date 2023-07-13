#!/usr/bin/env bash

# ROSA: kroko-cli autoinstall
# https://www.altlinux.org/Nvidia#Смена_открытых_драйверов_на_проприетарные[1]
# https://www.altlinux.org/Переход_на_драйверы_Nvidia_и_fglrx#Установка_проприетарных_драйверов_nvidia_и_fglrx_:

[ "$1" != "--run" ] && echo "Switch to using nVidia proprietary driver" && exit

. $(dirname $0)/common.sh

assure_root

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

# проверяем работоспособность драйвера на текущий момент
# TODO: добавить проверку на гибридную графику
# TODO: добавить аргумент --force для принудительной переустановки
if lspci -k | grep -A 2 -i "VGA" | grep "Kernel driver in use" | grep -q "nvidia" ; then
	echo "Already installed."
	exit
fi

epm full-upgrade || exit

# проверяем, совпадает ли ядро (пока нет такой проверки в update-kernel)
# TODO: добавить функцию в update-kernel и здесь использовать её
check_run_kernel () {
	if [ -n "$(ls /boot | grep "vmlinuz" | grep -vE 'vmlinuz-un-def|vmlinuz-std-def' | sort -r | head -n1 | grep $(uname -r))" ] ; then
		echo "Запущено самое свежее установленное ядро."
		return 0
	else
		echo "В системе есть ядро свежее запущенного."
		echo "Перезагрузитесь со свежим ядром и перезапустите: epm play switch-to-nvidia"
		return 1
	fi
}

check_run_kernel || exit

epm install --skip-installed nvidia_glx_common || exit

# используем команды из nvidia-install-driver
# устанавливает проприетарные драйвера nvidia и модули для ядра
a= apt-get install-nvidia || exit
a= x11presetdrv # сканирует PCI в /sys на предмет видеоплат производителя NVIDIA. Если таковые найдены, ищет пары драйверов ядерный+X-овый, совпадающие по версии. Переключает /lib/modules/`uname -r`/nVidia/nvidia.ko на выбранную версию
a= ldconfig # обновляет кэш информации о новейших версиях разделяемых библиотек

# отключаем nouveau
echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nvidia-x11.conf
a= rmmod nouveau

# удаляем /etc/X11/xorg.conf если он есть и в нём содержится nouveau или fbdev
if [ -e "/etc/X11/xorg.conf" ] && [ "$(grep -E 'nouveau|fbdev' "/etc/X11/xorg.conf")"  ] ; then
	 rm -v "/etc/X11/xorg.conf"
fi


epm install --skip-installed nvidia-settings nvidia-vaapi-driver ocl-nvidia libcuda vulkan-tools \
libnvidia-encode libnvidia-ngx libnvidia-opencl libvulkan1

# для работы 2-х и более видеокарт от nvidia необходимо добавить "nvidia-drm.modeset=1" в строку GRUB_CMDLINE_LINUX_DEFAULT= в файле /etc/default/grub и обновить grub

echo "Done. Just you need reboot your system to use nVidia proprietary drivers."
