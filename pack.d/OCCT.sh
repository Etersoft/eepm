#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

mkdir -p opt/occt
mv -v $TAR opt/occt/occt
chmod 0755 opt/occt/occt
# Disable automatic updates in future release
touch "opt/occt/disable_update"
# Use configs in home dir
touch "opt/occt/use_home_config"

cat <<EOF | create_file /usr/share/applications/occt.desktop
[Desktop Entry]
Name=OCCT
Comment=The best stability testing software
Exec=occt
Terminal=false
Icon=occt
Type=Application
StartupNotify=true
Categories=System;Utility;
StartupWMClass=OCCT
Keywords=linux;kernel;system;hardware;cpu;processor;capabilities;frequency;memory;ram;board;resources;sensors;devices;usb;pci;display;network;benchmark;test;
EOF

install_file ipfs://QmUvB4BvoUsQDxMUH9rZ3PMaZgYoBishLyGBwxdDQ1uHcU /usr/share/pixmaps/occt.png

erc pack $PKGNAME.tar usr opt

return_tar $PKGNAME.tar
