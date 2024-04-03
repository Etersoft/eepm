#!/usr/bin/env bash

# ROSA: kroko-cli autoinstall
# https://www.altlinux.org/Nvidia#Смена_открытых_драйверов_на_проприетарные[1]
# https://www.altlinux.org/Переход_на_драйверы_Nvidia_и_fglrx#Установка_проприетарных_драйверов_nvidia_и_fglrx_:

[ "$1" != "--run" ] && echo "Switch to using NVidia proprietary driver" && exit

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
if [ -z "$force" ] && a= lspci -k | grep -A 2 -i "VGA" | grep "Kernel driver in use" | grep -q "nvidia" ; then
	echo "Nvidia driver is already installed and used"
	exit
fi

# epm full-upgrade does too many things for this spec
epm update || fatal
# epm upgrade || fatal
epm update-kernel || fatal

# проверяем, совпадает ли ядро (пока нет такой проверки в update-kernel)
# TODO: добавить функцию в update-kernel и здесь использовать её
check_run_kernel () {
    # TODO: support kernel-image-rt
    USED_KFLAVOUR="$(uname -r | awk -F'-' '{print $(NF-2)}')-def"
    ls /boot | grep "vmlinuz" | grep -vE 'vmlinuz-un-def|vmlinuz-std-def' | grep "${USED_KFLAVOUR}" | sort -Vr | head -n1 | grep -q $(uname -r)
}

if check_run_kernel ; then
	echo "The most recently installed ${USED_KFLAVOUR} kernel is running."
else
	echo "The system has a ${USED_KFLAVOUR} kernel that is more recent than the one that was launched."
	echo "Reboot with a fresh ${USED_KFLAVOUR} kernel and restart: epm play switch-to-nvidia"
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
a= rmmod nouveau

# удаляем /etc/X11/xorg.conf если он есть и в нём содержится nouveau или fbdev
if [ -e "/etc/X11/xorg.conf" ] && [ "$(grep -E 'nouveau|fbdev|vesa' "/etc/X11/xorg.conf")"  ] ; then
	 rm -v "/etc/X11/xorg.conf"
fi


# Создаем список дополнительных пакетов и их описания. Все новые пакеты добавлять в этот список.
declare -A packages
packages=(
    ["nvidia-settings"]=" nvidia-settings — this is a tool for configuring the NVIDIA driver."
    ["nvidia-vaapi-driver"]="nvidia-vaapi-driver — this is a VA-API implementation that uses NVDEC as a backend"
    ["vulkan-tools"]="vulkan-tools is a set of tools for working with the Vulkan API."
    ["nvidia-modprobe"]="nvidia-modprobe — this is a elper to load kernel module and create device files."
    ["nvidia-xconfig"]="nvidia-xconfig — this is a ommand line tool for setup X11 for the NVIDIA driver"
    ["libvulkan1"]="libvulkan1 — these are the Vulkan loader libraries."
)
install_list=()

# Для каждого пакета спрашиваем пользователя, хочет ли он его установить
for package in "${!packages[@]}"; do
    echo "${packages[$package]}"
    read -p "Install $package? [Y/n] " answer
    answer=${answer,,}  # Преобразуем ответ в нижний регистр

    # Если ответ 'y' или пустой (вариант по умолчанию), то добавляем пакет в список для установки. В противном случае пропускаем.
    if [[ $answer == 'y' || $answer == '' ]]; then
        install_list+=($package)
	else
		continue
    fi
done

# Отдельно спрашиваем про пакеты для поддержки Cuda. Аналогично установке пакетов nvidia_glx_libs_XXX.XX.
#TODO необходимо разобраться с групами пакетов. Если Rosa и другие ветки репозиториев Alt позволяют, то придумать как применить nvidia_glx_libs_XXX.XX нужной версии.
read -p "Do you want to install additional packages to support Cuda? [Y/n] " answer

answer=${answer,,}

if [[ $answer == 'y' || $answer == '' ]]; then
	cuda_list=("ocl-nvidia" "libcuda" "libnvidia-encode" "libnvidia-ngx" "libnvidia-opencl" "libcudadebugger" "libnvcuvid" "libnvidia-api" "libnvidia-fbc" "libnvidia-ml" "libnvidia-nvvm" "libnvidia-ptxjitcompiler" "libnvoptix" "nvidia-smi")
    install_list+=($cuda_list)
else
	continue
fi

# Если список для установки не пуст, то устанавливаем пакеты
if [ ${#install_list[@]} -ne 0 ]; then
    echo "Installing packages: ${install_list[@]}"
    epm install --skip-installed ${install_list[@]}
else
    echo "You have not selected any additional packages to install."
fi

epm play i586-fix

# У этого фикса есть плюсы и минусы. Лучше предложить его применение на этапе установки.
echo "FIX: removing the "Unknown monitor" in the display settings in the Wayland session"
echo "There is a problem when some users have an additional "Unknown Monitor"."
echo  "Attention! This solution leads to the inability to log in to tty, to the absence of log output during boot (If Plymouth is not enabled)."

read -p "Do you want to apply FIX? [Y/n] " answer

answer=${answer,,}

if [[ $answer == 'y' || $answer == '' ]]; then
	if ! grep "initcall_blacklist=simpledrm_platform_driver_init" /etc/sysconfig/grub2 &>/dev/null ; then 
		echo "Creating a copy of /etc/sysconfig/grub2..."
		cp /etc/sysconfig/grub2 /etc/sysconfig/grub2.epmbak

		echo "Adding initcall_blacklist=simpledrm_platform_driver_init to the kernel parameters..."
		sed -i "s|^\(GRUB_CMDLINE_LINUX_DEFAULT='.*\)'\$|\1 initcall_blacklist=simpledrm_platform_driver_init'|" /etc/sysconfig/grub2

		echo "FIX применён."
	fi
else
	continue
fi

# Без этих интерфейсов будет некоректно работать уход в сон
echo "Activating nvidia power management interfaces."
systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
# Добавляем выделение места в системе для видеопамяти. Иначе интерфейсы не будут работать.
cat << _EOF_ > /etc/modprobe.d/nvidia_videomemory_allocation.conf
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/run
_EOF_

echo "Starting the initrd."
make-initrd

echo "Updating grub..."
update-grub

echo "Done. Just you need reboot your system to use nVidia proprietary drivers."

