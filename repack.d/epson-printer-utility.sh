#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_unirequires udev

# utility
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT
install_file opt/epson-printer-utility/rules/79-udev-epson.rules /etc/udev/rules.d/79-udev-epson.rules
install_file opt/epson-printer-utility/epson-printer-utility.desktop /usr/share/applications/epson-printer-utility.desktop

# backend
install_file usr/lib/epson-backend/ecbd.service /usr/lib/systemd/system/ecbd.service
mkdir -p var/cache/epson-backend
pack_dir /var/cache/epson-backend

# if command -v semodule > /dev/null 2>&1;then
#     semodule -i $BUILDROOT/usr/lib/epson-backend/epson_pol.pp
# fi

remove_dir /usr/lib/epson-backend/rc.d
remove_dir /usr/lib/epson-backend/scripts

fix_desktop_file /opt/epson-printer-utility/bin/epson-printer-utility

add_libs_requires

