#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

set_autoreq 'yes'

install_file /var/hasplm/init/hasplmd.service /etc/systemd/system/hasplmd.service
install_file /var/hasplm/init/aksusbd.service /etc/systemd/system/aksusbd.service

chmod -v u+w $BUILDROOT/usr/sbin/*

move_file /usr/sbin/aksusbd_x86_64 /usr/sbin/aksusbd
move_file /usr/sbin/hasplmd_x86_64 /usr/sbin/hasplmd

subst "s|aksusbd_x86_64|aksusbd|g" $BUILDROOT/etc/udev/rules.d/80-hasp.rules

mkdir -p $BUILDROOT/etc/init.d/
remove_dir /etc/init.d

touch $BUILDROOT/etc/hasplm/nethasp.ini
pack_file /etc/hasplm/nethasp.ini

remove_dir /var/hasplm/init
