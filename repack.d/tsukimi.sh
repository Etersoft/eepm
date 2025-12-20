#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT

add_requires "/usr/bin/clapper"

install_file https://github.com/tsukinaha/tsukimi/blob/main/resources/icons/moe.tsuna.tsukimi.png /usr/share/pixmaps/$PRODUCT.png
install_file $PRODUCTDIR/moe.tsuna.tsukimi.gschema.xml /usr/share/glib-2.0/schemas/moe.tsuna.tsukimi.gschema.xml

# create desktop file
cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Tsukimi
Exec=$PRODUCT
Type=Application
Icon=$PRODUCT
Categories=AudioVideo;
StartupWMClass=moe.tsuna.tsukimi
EOF

