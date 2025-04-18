#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/bin/
mv -v $TAR usr/bin/occt
chmod 0755 usr/bin/occt

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
Keywords=linux;kernel;system;hardware;cpu;processor;capabilities;frequency;memory;ram;board;resources;sensors;devices;usb;pci;display;network;benchmark;test;
EOF

install_file ipfs://QmUvB4BvoUsQDxMUH9rZ3PMaZgYoBishLyGBwxdDQ1uHcU /usr/share/pixmaps/occt.png

erc pack $PKGNAME.tar usr

return_tar $PKGNAME.tar
