#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=affinity3
PRODUCTDIR=/opt/eepm-wine/$PRODUCT

. $(dirname $0)/common.sh

add_requires winetricks dotnet tar xz zstd

add_bin_link_command $PRODUCT $PRODUCTDIR/run.sh
add_bin_link_command affinity3-setup $PRODUCTDIR/setup.sh

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Affinity
Comment=Professional creative suite
Exec=$PRODUCT %U
Type=Application
Terminal=false
StartupNotify=true
Icon=$PRODUCT
StartupWMClass=affinity.exe
Categories=Graphics;
MimeType=x-scheme-handler/affinity3;
EOF

install_file "https://raw.githubusercontent.com/seapear/AffinityOnLinux/main/Assets/Icons/Affinity-Canva.svg" /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg
