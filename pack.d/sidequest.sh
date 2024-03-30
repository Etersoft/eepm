#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh


# SideQuest-0.10.39.tar.xz
BASENAME=$(basename $TAR .tar.xz)
VERSION=$(echo $BASENAME | sed -e 's|SideQuest-||' | sed -e 's|.tar.xz||')
[ -n "$VERSION" ] || fatal "Can't get package version"

ln -s $TAR $BASENAME.tar.xz
erc unpack $BASENAME.tar.xz || fatal

mkdir -p opt
mkdir -p usr/share/applications/

mv $BASENAME* opt/sidequest

for res in 16x16 24x24 32x32 48x48 64x64 128x128 256x256 512x512 1024x1024; do
    install -dm755 "usr/share/icons/hicolor/${res}/apps/"
    install -m644 opt/sidequest/resources/app.asar.unpacked/build/icons/${res}.png usr/share/icons/hicolor/${res}/apps/sidequest.png
done

# create desktop file
cat <<EOF > usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=SideQuest
Comment=The SideQuest desktop application
Exec=$PRODUCT %U
Icon=$PRODUCT
Terminal=false
StartupNotify=true
Categories=Development;Game;HardwareSettings
StartupWMClass=SideQuest
MimeType=x-scheme-handler/sidequest;
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
