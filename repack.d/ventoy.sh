#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=ventoy
PRODUCTDIR=/opt/ventoy

. $(dirname $0)/common.sh

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Type=Application
Icon=ventoy
Name=Ventoy
Exec=ventoygui
Terminal=false
Hidden=false
Categories=Utility
Comment=Ventoy2Disk GUI
StartupWMClass=Ventoy2Disk.gtk3
EOF

epm tool eget -O- https://aur.archlinux.org/cgit/aur.git/plain/sanitize.patch?h=ventoy-bin > opt/ventoy/sanitize.patch

epm assure /usr/bin/patch

cd opt/ventoy

patch -Np1 -i "sanitize.patch"
rm -v sanitize.patch

# Qt5 dependencies (system Qt, not bundled)
add_unirequires libQt5Core.so.5 libQt5Gui.so.5 libQt5Widgets.so.5
