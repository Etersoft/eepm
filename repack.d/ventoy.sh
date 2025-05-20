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

epm tool eget -O opt/ventoy/sanitize.patch https://aur.archlinux.org/cgit/aur.git/plain/sanitize.patch?h=ventoy-bin
epm tool eget -O opt/ventoy/desktop_session.patch https://aur.archlinux.org/cgit/aur.git/plain/desktop_session.patch?h=ventoy-bin

epm assure /usr/bin/patch

cd opt/ventoy

patch  -p0 < "sanitize.patch"
patch -Np1 -i "desktop_session.patch"

rm -v sanitize.patch
rm -v desktop_session.patch
rm -v VentoyWeb.sh.orig
rm -v tool/VentoyWorker.sh.orig
rm -v tool/distro_gui_type.json.orig
rm -v tool/ventoy_lib.sh.orig



add_libs_requires
