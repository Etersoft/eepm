#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
PRODUCT=davinci-resolve

. $(dirname $0)/common.sh

# DaVinci_Resolve_18.6.5_Linux.run
BASENAME=$(basename $1 .run)
VERSION=$(echo $BASENAME | sed -e 's|DaVinci_Resolve_||' -e 's|_Linux||')
mkdir -p opt/davinci-resolve

$1 --appimage-extract &> /dev/null

mv -v squashfs-root/* opt/davinci-resolve/

install -Dm0644 opt/davinci-resolve/share/default-config.dat -t opt/$PRODUCT/configs
install -Dm0644 opt/davinci-resolve/share/log-conf.xml -t opt/$PRODUCT/configs
install -Dm0644 opt/davinci-resolve/share/default_cm_config.bin -t opt/$PRODUCT/DolbyVision

install -Dm0644 opt/davinci-resolve/share/*.desktop -t usr/share/applications
install -Dm0644 opt/davinci-resolve/share/DaVinciResolve.directory -t usr/share/desktop-directories
install -Dm0644 opt/davinci-resolve/share/DaVinciResolve.menu -t etc/xdg/menus
install -Dm0644 opt/davinci-resolve/graphics/DV_Resolve.png -t usr/share/icons/hicolor/64x64/apps
install -Dm0644 opt/davinci-resolve/graphics/DV_ResolveProj.png -t usr/share/icons/hicolor/64x64/apps
install -Dm0644 opt/davinci-resolve/share/resolve.xml -t usr/share/mime/packages

install -Dm0644 opt/davinci-resolve/share/etc/udev/rules.d/99-BlackmagicDevices.rules -t usr/lib/udev/rules.d
install -Dm0644 opt/davinci-resolve/share/etc/udev/rules.d/99-ResolveKeyboardHID.rules -t usr/lib/udev/rules.d
# install -Dm0644 opt/davinci-resolve/share/etc/udev/rules.d/99-DavinciPanel.rules -t usr/lib/udev/rules.d

echo "StartupWMClass=resolve" >> usr/share/DaVinciResolve.desktop

subst "s|RESOLVE_INSTALL_LOCATION|/opt/davinci-resolve|" usr/share/applications/*.desktop 
subst "s|RESOLVE_INSTALL_LOCATION|/opt/davinci-resolve|" usr/share/desktop-directories/*
# fix for libpango.so error too

rm -v opt/davinci-resolve/libs/libglib-2.0.so.0
# ln -s /usr/lib/libglib-2.0.so.0 opt/davinci-resolve/libs/libglib-2.0.so.0

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr etc || fatal

return_tar $PKGNAME.tar
