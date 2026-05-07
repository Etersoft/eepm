#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

mkdir -p usr/bin

erc --here unpack $TAR || fatal

cp "megatools-$VERSION-linux-x86_64/megatools" "usr/bin/"

chmod 755 "usr/bin/megatools"

for cmd in df dl get ls test export mkdir put reg rm copy
do
  ln -snf "/usr/bin/megatools" "usr/bin/mega$cmd"
done

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

return_tar $PKGNAME.tar
