#!/bin/bash

SUPPORTEDARCHES=''
DESCRIPTION="Install and configure Waydroid"

. $(dirname $0)/common.sh


[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux are supported"

epm assure lspci pciutils || exit

display_help()
{
    echo "
Use: epm prescription waydroid [option]
--gpu
	Select GPU for Waydroid

--init
    Initialize Waydroid

--integrate
	Enable desktop window integration for Waydroid

--software-render
	Use software render in Waydroid (maybe fix work in Nvidia)

--help
	Display this page
"
    exit
}

waydroid_install () {
	epm update-kernel --add-kernel-options psi=1

	epm update || fatal
	epm update-kernel || fatal

	if ! epm update-kernel --check-run-kernel ; then
		fatal
	fi

	USED_KFLAVOUR="$(epm update-kernel --used-kflavour)"
	epm install --skip-installed kernel-modules-anbox-$USED_KFLAVOUR libgbinder1 waydroid || fatal

	a= update-grub

	echo "binder_linux" > /etc/modules-load.d/waydroid.conf

	echo "Done. Just you need type epm prescription waydroid --init and reboot your system to use waydroid."
}

waydroid_select_gpu () {
	echo "Select GPU for Waydroid"
	gpu_info=$(a='' lspci -nn | grep '\[03')
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

case "${3}" in
    '--gpu' )
        assure_root
        waydroid_select_gpu ;;

    '--init')
        assure_root
        waydroid_init ;;

    '--integrate')
		assure_root
        waydroid_integrate ;;

    '--software-render')
		assure_root
        waydroid_software_rendering ;;

    '--clean')
		assure_root
		for file in /var/lib/waydroid/lxc/waydroid/config_nodes.bak /etc/modules-load.d/waydroid.conf; do
			[ -f "$file" ] && rm -vf "$file"
		done
		epm update-kernel --remove-kernel-options psi=1
		a= update-grub
		exit 0
        ;;

    '--help')
        display_help;;

        *)
		assure_root
		waydroid_install ;;
esac
