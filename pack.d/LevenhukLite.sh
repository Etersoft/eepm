#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

# lvh_software_levenhuklite_4_11_2023_12.zip
erc unpack $TAR || fatal
cd *

erc unpack LevenhukLite.x64.tar.bz2 || fatal
sed -n -e '1,/^exit 0$/!p' LevenhukLite.x64.sh > LevenhukLite.tgz

erc unpack LevenhukLite.tgz || fatal
cd LevenhukLite

mkdir -p opt/$PRODUCT
mkdir -p usr/share/icons/hicolor/128x128/apps/
mkdir -p usr/lib/udev/rules.d/
mkdir -p usr/share/applications

cp -a i18n opt/$PRODUCT/
install -m0755 LevenhukLite opt/$PRODUCT/
install -m0755 liblevenhukcam.so opt/$PRODUCT/
install -m0755 liblevenhuknam.so opt/$PRODUCT/
install -Dpm0644 LevenhukLite.png usr/share/icons/hicolor/128x128/apps/
install -Dm0644 99-levenhukcam.rules usr/lib/udev/rules.d/
install -Dpm0644 LevenhukLite.desktop usr/share/applications

PKGNAME=$PRODUCT-$VERSION
erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar 
