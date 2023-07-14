#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh


#REQUIRES="fonts-ttf-liberation, fonts-ttf-dejavu"
#subst "s|^\(Name: .*\)$|# Converted from original package requires\nRequires:$REQUIRES\n\1|g" $SPEC

remove_dir /etc/cron.d
remove_dir /etc/logrotate.d
remove_dir /etc/xdg/menus/applications-merged

# ALT bug 43751
remove_file /usr/share/desktop-directories/wps-office.directory

# ALT bug 45683
remove_file /opt/kingsoft/wps-office/office6/wpscloudsvr

#epm install --skip-installed bzlib fontconfig libalsa libcairo libcups libdrm libfreetype /usr/bin/perl zlib libXv glib2 libatk libcairo-gobject libEGL libgdk-pixbuf libgio libGL libgst-plugins1.0 libgstreamer1.0 libgtk+2 libgtk+3 libpango libpulseaudio libsqlite3 libX11 libxcb libxcb-render-util libXcomposite libXext libXfixes libxkbcommon libxkbcommon-x11 libXrender

