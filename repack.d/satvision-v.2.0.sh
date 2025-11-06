#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=satvision-v.2.0

. $(dirname $0)/common.sh

# too many side effects due the space
move_to_opt "/opt/Satvision V.2.0"

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Satvision V.2.0
Exec=$PRODUCT %F
Type=Application
StartupNotify=true
Icon=$PRODUCT
StartupWMClass=Satvision V.2.0
Categories=Network;
EOF

epm assure /usr/bin/convert
convert .$PRODUCTDIR/main.ico .$PRODUCTDIR/main.png

install_file .$PRODUCTDIR/main.png /usr/share/pixmaps/$PRODUCT.png

add_bin_link_command $PRODUCT "$PRODUCTDIR/Satvision V.2.0"

add_libs_requires
