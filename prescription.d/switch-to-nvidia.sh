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
if [ "$(inxi -G | grep "OpenGL: renderer" | grep "NVIDIA")" ] ; then
	echo "Already installed."
	exit
fi

epm update || exit
epm upgrade || exit

# TODO: проверяем, совпадает ли ядро (вариант ниже требует доработки)
# if [ ! $(update-kernel -l | grep -i "$(uname -r | awk -F'-' '{print $1}')") ] ; then
 	epm update-kernel || exit
#	echo "Перезагрузитесь с новой версией ядра и повторно запустите команду epm play switch-to-nvidia"
#	exit
# fi

epm install --skip-installed nvidia_glx_common || exit
nvidia-install-driver || exit

echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nvidia-x11.conf
installkernel $(uname -r)

if [ -e "/etc/X11/xorg.conf" ] && [ "$(grep -E 'nouveau|fbdev' "/etc/X11/xorg.conf")"  ] ; then
	 rm "/etc/X11/xorg.conf"
fi

epm install --skip-installed nvidia-settings nvidia-vaapi-driver ocl-nvidia libcuda vulkan-tools \
libnvidia-encode libnvidia-ngx libnvidia-opencl i586-libcuda i586-libnvidia-encode i586-libnvidia-opencl
epm install --skip-installed libvulkan1 i586-libvulkan1

# пакет который только в Сизифе (на данный момент):
# apt-get install nvidia-wine

# для работы 2-х и более видеокарт от nvidia необходимо добавить "nvidia-drm.modeset=1" в строку GRUB_CMDLINE_LINUX_DEFAULT= в файле /etc/default/grub и обновить grub

echo "Done. Just you need reboot your system to use nVidia proprietary drivers."
