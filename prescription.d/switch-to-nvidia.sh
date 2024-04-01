#!/usr/bin/env bash

# ROSA: kroko-cli autoinstall
# https://www.altlinux.org/Nvidia#Смена_открытых_драйверов_на_проприетарные[1]
# https://www.altlinux.org/Переход_на_драйверы_Nvidia_и_fglrx#Установка_проприетарных_драйверов_nvidia_и_fglrx_:

[ "$1" != "--run" ] && echo "Переход на использование проприетарных драйверов nvidia" && exit

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
	echo "Драйвера nvidia уже установлены и запущены."
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
	echo "Запущено самое свежее установленное ${USED_KFLAVOUR} ядро."
else
	echo "В системе есть ${USED_KFLAVOUR} ядро свежее запущенного."
	echo "Перезагрузитесь со свежим ${USED_KFLAVOUR} ядром и перезапустите: epm play switch-to-nvidia"
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
    ["nvidia-settings"]=" nvidia-settings — это инструмент для настройки видеокарт NVIDIA."
    ["nvidia-vaapi-driver"]="nvidia-vaapi-driver — это драйвер для аппаратного декодирования видео на видеокартах NVIDIA."
    ["vulkan-tools"]="vulkan-tools — это набор инструментов для работы с Vulkan API."
    ["nvidia-modprobe"]="nvidia-modprobe — это утилита для загрузки модулей ядра NVIDIA."
    ["nvidia-xconfig"]="nvidia-xconfig — это инструмент для управления конфигурацией X server для видеокарт NVIDIA."
    ["libvulkan1"]="libvulkan1 — это библиотека, которая предоставляет API Vulkan 1.x."
)
install_list=()

# Для каждого пакета спрашиваем пользователя, хочет ли он его установить
for package in "${!packages[@]}"; do
    echo "${packages[$package]}"
    read -p "Установить $package? [Y/n] " answer
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
read -p "Вы хотите установить дополнительные пакеты для поддержки Cuda? [Y/n] " answer

answer=${answer,,}

if [[ $answer == 'y' || $answer == '' ]]; then
	cuda_list=("ocl-nvidia" "libcuda" "libnvidia-encode" "libnvidia-ngx" "libnvidia-opencl" "libcudadebugger" "libnvcuvid" "libnvidia-api" "libnvidia-fbc" "libnvidia-ml" "libnvidia-nvvm" "libnvidia-ptxjitcompiler" "libnvoptix" "nvidia-smi")
    install_list+=($cuda_list)
else
	continue
fi

# Если список для установки не пуст, то устанавливаем пакеты
if [ ${#install_list[@]} -ne 0 ]; then
    echo "Устанавливаем пакеты: ${install_list[@]}"
    epm install --skip-installed ${install_list[@]}
else
    echo "Вы не выбрали ни одного дополнительного пакета для установки."
fi

epm play i586-fix

# У этого фикса есть плюсы и минусы. Лучше предложить его применение на этапе установки.
echo "FIX: убираем «Неизвестный монитор» в настройках дисплеев в сессии Wayland"
echo "Существует проблема, когда у некоторых пользователей появляется дополнительный «Неизвестный монитор»."
echo  "Внимание! Данное решение приводит к невозможности входа в tty, к отсутствию вывода логов во время загрузки (Если не включён Plymouth)."

read -p "Вы хотите применить FIX? [Y/n] " answer

answer=${answer,,}

if [[ $answer == 'y' || $answer == '' ]]; then
	if ! grep "initcall_blacklist=simpledrm_platform_driver_init" /etc/sysconfig/grub2 &>/dev/null ; then 
		echo "Создание копии /etc/sysconfig/grub2..."
		cp /etc/sysconfig/grub2 /etc/sysconfig/grub2.epmbak

		echo "Добавление initcall_blacklist=simpledrm_platform_driver_init в параметры ядра..."
		sed -i "s|^\(GRUB_CMDLINE_LINUX_DEFAULT='.*\)'\$|\1 initcall_blacklist=simpledrm_platform_driver_init'|" /etc/sysconfig/grub2

		echo "FIX применён."
	fi
else
	continue
fi

# Без этих служб будет некоректно работать уход в сон
echo "Активируем службы управления питания NVIDIA."
systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service


echo "Запускаем регенерацию initrd."
make-initrd

echo "Обновляем grub..."
update-grub

echo "Выполнено. Перезагрузите систему для использования проприетарных драйверов nvidia."

