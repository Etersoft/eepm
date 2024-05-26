#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

install_file https://raw.githubusercontent.com/tsukinaha/tsukimi/main/resources/ui/icons/$PRODUCT.png /usr/share/pixmaps/$PRODUCT.png
install_file https://raw.githubusercontent.com/tsukinaha/tsukimi/main/moe.tsuna.tsukimi.gschema.xml /usr/share/glib-2.0/schemas/moe.tsuna.tsukimi.gschema.xml

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

# glib-compile-schemas /usr/share/glib-2.0/schemas/

add_requires "/usr/bin/clapper"

add_libs_requires
