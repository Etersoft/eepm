#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=portproton
PRODUCTDIR=/opt/PortProton

. $(dirname $0)/common.sh

move_to_opt /PortWINE-master
remove_dir $PRODUCTDIR/portwine_install_script

add_bin_link_command $PRODUCT $PRODUCTDIR/data_from_portwine/scripts/start.sh

install_file $PRODUCTDIR/data_from_portwine/img/w.png /usr/share/pixmaps/$PRODUCT.png

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=PortProton
Comment=PortProton
Exec=$PRODUCT %F
Path=$PRODUCTDIR/data_from_portwine/scripts
Icon=$PRODUCT
Type=Application
Categories=Game;
StartupNotify=true
MimeType=application/x-ms-dos-executable;application/x-wine-extension-msp;application/x-msi;application/x-msdos-program
Keywords=wine;games;
EOF
pack_file /usr/share/applications/$PRODUCT.desktop

# https://github.com/Castro-Fidel/PortWINE/pull/36
subst 's|elif|else|' $BUILDROOT$PRODUCTDIR/data_from_portwine/scripts/portwine_db/WorldOfTanksEnCoreLauncher

add_requires bubblewrap cabextract curl gamemode icoutils libvulkan1 vulkan-tools wget zenity zstd libd3d libMesaOpenCL
epm install -skip-installed vulkan-tools

filter_from_requires xneur

mkdir -p $BUILDROOT/var/lib/$PRODUCT
# TODO: use some group?
chmod a+rwX $BUILDROOT/var/lib/$PRODUCT
ln -s /var/lib/$PRODUCT $BUILDROOT$PRODUCTDIR/data
pack_file $PRODUCTDIR/data
pack_file /var/lib/$PRODUCT
