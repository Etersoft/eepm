#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/teamviewer

UNIREQUIRES="xdg-utils
libEGL.so.1 libGL.so.1 libICE.so.6 libSM.so.6 libX11-xcb.so.1 libX11.so.6 libXext.so.6 libc.so.6 libdbus-1.so.3 libdl.so.2
libfontconfig.so.1 libfreetype.so.6
libglib-2.0.so.0 libgthread-2.0.so.0 libm.so.6
libminizip.so.1 libnspr4.so libnss3.so libnssutil3.so libplc4.so libplds4.so libpthread.so.0 libresolv.so.2 librt.so.1
libsmime3.so libsoftokn3.so libuuid.so.1 libxcb-glx.so.0 libxcb-render.so.0 libxcb-shape.so.0 libxcb-shm.so.0 libxcb-sync.so.1 libxcb-xfixes.so.0 libxcb.so.1 libz.so.1"

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

