#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=bitrix24
PRODUCTCUR=Bitrix24
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common.sh

remove_dir /etc/apt/sources.list.d
remove_dir /etc/yum.repos.d
remove_dir /etc/apt/trusted.gpg.d

add_bin_exec_command $PRODUCTCUR $PRODUCTDIR/$PRODUCTCUR
add_bin_exec_command $PRODUCTCUR-web $PRODUCTDIR/$PRODUCTCUR-web

add_bin_link_command $PRODUCT $PRODUCTCUR
add_bin_link_command $PRODUCT-web $PRODUCTCUR-web

# TODO:
# libqt5_shim.so
#ignore_lib_requires "libQt5*.so.5"
ignore_lib_requires libQt5Core.so.5 libQt5Gui.so.5 libQt5Widgets.so.5

# TODO:
# libqt6_shim.so
#ignore_lib_requires "libQt6*.so.6"
ignore_lib_requires libQt6Core.so.6 libQt6Gui.so.6  libQt6Widgets.so.6

if [ -f ./$PRODUCTDIR/ffmpeg ] ; then
   # use external ffmpeg
   add_unirequires ffmpeg
   remove_file $PRODUCTDIR/ffmpeg
fi

add_libs_requires
