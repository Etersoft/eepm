#!/bin/bash

[ "$1" != "--run" ] && echo "Install and configure Waydroid" && exit

. $(dirname $0)/common.sh


[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux are supported"

epm assure lspci pciutils || exit

check_run_kernel () {
    USED_KFLAVOUR="$(uname -r | awk -F'-' '{print $(NF-2)}')-def"
    ls /boot | grep "vmlinuz" | grep -vE 'vmlinuz-un-def|vmlinuz-std-def' | grep "${USED_KFLAVOUR}" | sort -Vr | head -n1 | grep -q $(uname -r)
}

display_help()
{
    echo "
Use: epm play waydroid [option]
--gpu
	Select GPU for Waydroid

--init
    Initialize Waydroid

--install
	Instal Waydroid

--integrate
	Enable desktop window integration for Waydroid

--clean
	Clean all Waydroid files

--software-render
	Use software render in Waydroid (maybe fix work in Nvidia)
"
    exit
}

case "${3}" in
    '--gpu' )
        assure_root
        waydroid_select_gpu ;;

    '--init')
        assure_root
        waydroid_init ;;

    '--install')
        assure_root
        waydroid_install ;;

    '--integrate')
        waydroid_integrate ;;

    '--software-render')
		assure_root
        waydroid_software_rendering ;;

    '--help' | *)
        display_help;;
esac


waydroid_install () {
	if ! grep "psi=1" /etc/sysconfig/grub2 &>/dev/null ; then
		cp /etc/sysconfig/grub2 /etc/sysconfig/grub2.epmbak
		sed -i "s|^\(GRUB_CMDLINE_LINUX_DEFAULT='.*\)'\$|\1 psi=1'|" /etc/sysconfig/grub2
	fi

	epm update || fatal
	epm update-kernel || fatal

	if check_run_kernel ; then
		echo "The most newer installed ${USED_KFLAVOUR} kernel is running."
	else
		echo "The system has a newer ${USED_KFLAVOUR} kernel."
		echo "Reboot with a fresh ${USED_KFLAVOUR} kernel and restart: epm play waydroid"
		fatal
	fi

	epm install --skip-installed kernel-modules-anbox-$USED_KFLAVOUR libgbinder1 waydroid || fatal

	a= update-grub

	echo "Waydroid has been installed"
}

waydroid_select_gpu () {
	echo "Select GPU for Waydroid"
	gpu_info=$(lspci -nn | grep '\[03')
	gpu_number=$(echo "$gpu_info" | awk '{print $1}')
	gpu_name=$(echo "$gpu_info" | grep -oP '(?<=: ).*')

	if [ -z "$gpu_info" ]; then
	echo "No GPU devices found."
	exit 1
	fi

	echo "Available GPU device"
	for i in "${!gpu_number[@]}"; do
	echo "$((i)). ${gpu_number[$i]} ${gpu_name}"
	done

	# Prompt the user to select a device ID
	while true; do
	read -p "Enter the number of the GPU device to use: " selected_gpu_num
	if ! [[ "$selected_gpu_num" =~ ^[0-9]+$ ]]; then
		echo "Invalid entry: $selected_gpu_num is not a number."
		continue
	fi

	if (( selected_gpu_num < 0 || selected_gpu_num >= ${#gpu_number[@]} )); then
		echo "Invalid entry: $selected_gpu_num is not a valid option."
		continue
	fi
	selected_gpu=${gpu_number[$selected_gpu_num]}
	break
	done

	card=$(ls -l /dev/dri/by-path/ | grep -i $selected_gpu | grep -o "card[0-9]")
	rendernode=$(ls -l /dev/dri/by-path/ | grep -i $selected_gpu | grep -o "renderD[1-9][1-9][1-9]")

	cp /var/lib/waydroid/lxc/waydroid/config_nodes /var/lib/waydroid/lxc/waydroid/config_nodes.bak
	sed -i '/dri/d' /var/lib/waydroid/lxc/waydroid/config_nodes
	echo "lxc.mount.entry = /dev/dri/$card dev/dri/card0 none bind,create=file,optional 0 0" >> /var/lib/waydroid/lxc/waydroid/config_nodes
	echo "lxc.mount.entry = /dev/dri/$rendernode dev/dri/renderD128 none bind,create=file,optional 0 0" >> /var/lib/waydroid/lxc/waydroid/config_nodes
}

waydroid_init () {
	serv on waydroid-container
	waydroid init -c 'https://ota.waydro.id/system' -v 'https://ota.waydro.id/vendor'
}

waydroid_integrate () {
	waydroid prop set persist.waydroid.multi_windows true
}

waydroid_software_rendering () {
	sed -i "s/ro.hardware.gralloc=.*/ro.hardware.gralloc=default/g" /var/lib/waydroid/waydroid_base.prop
	sed -i "s/ro.hardware.egl=.*/ro.hardware.egl=swiftshader/g" /var/lib/waydroid/waydroid_base.prop
}
