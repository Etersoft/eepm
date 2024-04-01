#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=snap4arduino

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/run

# TODO: copy icons

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Type=Application
Version=1.0
Icon=$PRODUCTDIR/icons/128x128x32.png
Exec=$PRODUCT
Name=Snap4Arduino
Name[en]=Snap4Arduino
GenericName[en]=Use Snap! to control Arduino boards. Arduino goes lambda!
EOF

add_libs_requires
