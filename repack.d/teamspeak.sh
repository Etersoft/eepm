#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTCUR=TeamSpeak
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCTCUR $PRODUCTDIR/TeamSpeak
add_bin_link_command $PRODUCT $PRODUCTCUR

add_electron_deps
fix_chrome_sandbox

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Encoding=UTF-8
Name=TeamSpeak
GenericName=TeamSpeak - Voice communication
Comment=TeamSpeak is software for quality voice communication via the Internet
Exec=teamspeak
Icon=teamspeak
StartupNotify=true
Terminal=false
Type=Application
Categories=Network;Application
StartupWMClass=TeamSpeak
EOF

install_file .$PRODUCTDIR/logo-128.png /usr/share/pixmaps/$PRODUCT.png
