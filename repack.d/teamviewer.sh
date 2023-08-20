#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/teamviewer

UNIREQUIRES="xdg-utils"

. $(dirname $0)/common.sh

TV_DBUS_FILE_GUI='com.teamviewer.TeamViewer.service'
TV_DBUS_FILE_DESKTOP='com.teamviewer.TeamViewer.Desktop.service'
TV_POLKIT_FILE='com.teamviewer.TeamViewer.policy'
#put_link /usr/share/dbus-1/services $TV_DBUS_FILE_GUI
#put_link /usr/share/dbus-1/services $TV_DBUS_FILE_DESKTOP
#put_link /usr/share/polkit-1/actions $TV_POLKIT_FILE
install_file $PRODUCTDIR/tv_bin/script/teamviewerd.service /lib/systemd/system/teamviewerd.service

# don't use packed xdg-utils
remove_dir /opt/teamviewer/tv_bin/xdg-utils

remove_file /opt/teamviewer/tv_bin/script/teamviewerd.sysv

add_libs_requires
