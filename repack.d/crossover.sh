#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/cxoffice

. $(dirname $0)/common.sh

remove_dir /usr/lib

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Crossover
Comment=Run Windows Programs on Linux
Exec=$PRODUCT %f
Icon=$PRODUCT.png
Terminal=false
StartupNotify=true
StartupWMClass=crossover
Categories=Wine;Utility
EOF

for i in 16 32 64 128 256 ; do
    install_file $PRODUCTDIR/share/icons/${i}x${i}/crossover.png /usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png 
done

add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT

if [ "$(epm print info -s)" = "alt" ]; then
    ignore_lib_requires 'libcapi20.so.3()(64bit)' 'libcapi20.so.3'
    add_requires 'libvte3-gir' 'libvulkan1' 'i586-libvulkan1' 'i586-libnss-mdns' 'libnss-mdns'
    add_requires 'i586-gst-plugins-bad1.0' 'gst-plugins-bad1.0' 'gst-plugins-base1.0' 'i586-gst-plugins-base1.0' 'gst-plugins-good1.0' 'i586-gst-plugins-good1.0' 'gst-plugins-ugly1.0' 'i586-gst-plugins-ugly1.0'
fi

add_libs_requires