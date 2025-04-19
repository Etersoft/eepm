#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

mkdir -p opt/OCCT
mv -v $TAR opt/OCCT/occt
chmod 0755 opt/OCCT/occt

cat <<EOF | create_file /opt/OCCT/OCCT.config.json
{
  "CheckForUpdates": "Disabled",
}
EOF

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
