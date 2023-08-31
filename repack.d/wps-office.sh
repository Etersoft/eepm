#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/kingsoft/wps-office

. $(dirname $0)/common.sh

#REQUIRES="fonts-ttf-liberation, fonts-ttf-dejavu"
#subst "s|^\(Name: .*\)$|# Converted from original package requires\nRequires:$REQUIRES\n\1|g" $SPEC

remove_dir /etc/cron.d
remove_dir /etc/logrotate.d
remove_dir /etc/xdg/menus/applications-merged

# ALT bug 43751
remove_file /usr/share/desktop-directories/wps-office.directory

# ALT bug 45683
remove_file $PRODUCTDIR/office6/wpscloudsvr

# linked with missed libkappessframework.so()(64bit)
remove_file $PRODUCTDIR/office6/addons/pdfbatchcompression/libpdfbatchcompressionapp.so

# hack to fix bug somewhere in linking
ignore_lib_requires "libc++.so"

add_libs_requires
