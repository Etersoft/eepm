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

# https://bugs.etersoft.ru/show_bug.cgi?id=17812
# Fix for icu>=71.1
#remove_file $PRODUCTDIR/office6/libstdc++.so*

# Use system libjpeg
remove_file $PRODUCTDIR/office6/libjpeg.so*

# hack to fix bug somewhere in linking
ignore_lib_requires "libc++.so"

# QT is prebuilded
#ignore_lib_requires "libQtCore.so.4 libQtNetwork.so.4 libQtXml.so.4"
remove_file $PRODUCTDIR/office6/librpcwpsapi.so
remove_file $PRODUCTDIR/office6/librpcwppapi.so

# WPS Office provide libuof.so()(64bit) itself
ignore_lib_requires "libuof.so"

# Fix wps deprecated python2 command
# https://aur.archlinux.org/cgit/aur.git/tree/fix-wps-python-parse.patch?h=wps-office-cn
subst 's/python -c '\''import sys, urllib; print urllib.unquote(sys.argv\[1\])'\''/python3 -c '\''import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))'\''/' $BUILDROOT/usr/bin/wps

# ошибка: Macro %20sequence not found
remove_file $PRODUCTDIR/office6/mui/zh_CN/resource/help/etrainbow/images/Ribbon/custom_%20sequence.gif
#remove_dir $PRODUCTDIR/office6/mui/zh_CN/resource/help/etrainbow/images

add_libs_requires
