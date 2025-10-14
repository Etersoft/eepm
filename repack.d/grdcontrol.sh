#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh


install_file /opt/guardant/grdcontrol/grdcontrol.service /etc/systemd/system/grdcontrol.service
install_file /opt/guardant/grdcontrol/95-grdnt.rules /etc/udev/rules.d/95-grdnt.rules

add_bin_link_command license_wizard /opt/guardant/grdcontrol/license_wizard


add_libs_requires
