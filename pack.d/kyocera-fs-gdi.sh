#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# LinuxDrv_1.1203_FS-1x2xMFP.zip contains Linux/64bit/Global/English.tar.gz
erc --here unpack $TAR || fatal
erc --here unpack Linux/64bit/Global/English.tar.gz || fatal

VERSION=1.1203

mkdir -p usr/share/ppd/kyocera
cp English/Kyocera_FS*.ppd usr/share/ppd/kyocera/ || fatal

mkdir -p usr/lib/cups/filter
cp English/rastertokpsl usr/lib/cups/filter/rastertokpsl || fatal
chmod 755 usr/lib/cups/filter/rastertokpsl

erc pack $PRODUCT-$VERSION.tar usr || fatal
return_tar $PRODUCT-$VERSION.tar
