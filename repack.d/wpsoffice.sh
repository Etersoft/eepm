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
remove_dir /etc/xdg

# ALT bug 43751
remove_file /usr/share/desktop-directories/wps-office.directory

# ALT bug 45683
remove_file $PRODUCTDIR/office6/wpscloudsvr

# linked with missed libkappessframework.so()(64bit)
remove_file $PRODUCTDIR/office6/addons/pdfbatchcompression/libpdfbatchcompressionapp.so

# https://github.com/NixOS/nixpkgs/commit/da74ad3a905aa45ee6e4f8b4b69b56930195adcb
# Use system libjpeg
remove_file $PRODUCTDIR/office6/libjpeg.so*

# Fix theme system on WPS Office 11
is_stdcpp_enough "12.1" && remove_file $PRODUCTDIR/office6/libstdc++.so*

# hack to fix bug somewhere in linking
ignore_lib_requires "libc++.so"

# avoid dependency to Qt 4
remove_file $PRODUCTDIR/office6/librpcwpsapi.so
remove_file $PRODUCTDIR/office6/librpcwppapi.so
remove_file $PRODUCTDIR/office6/librpcetapi.so

# WPS Office provide libuof.so()(64bit) itself
ignore_lib_requires "libuof.so"

# Fix wps deprecated python2 command
# https://aur.archlinux.org/cgit/aur.git/tree/fix-wps-python-parse.patch?h=wps-office-cn
subst 's/python -c '\''import sys, urllib; print urllib.unquote(sys.argv\[1\])'\''/python3 -c '\''import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))'\''/' $BUILDROOT/usr/bin/wps

# ошибка: Macro %20sequence not found
remove_file $PRODUCTDIR/office6/mui/zh_CN/resource/help/etrainbow/images/Ribbon/custom_%20sequence.gif
#remove_dir $PRODUCTDIR/office6/mui/zh_CN/resource/help/etrainbow/images

add_libs_requires
