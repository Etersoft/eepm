#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# linuxbrowser0.6.1-obs23.0.2-64bit.tgz
BASENAME=$(basename $TAR .tgz)
VERSION=$(echo $BASENAME | sed -e 's|^linuxbrowser||' -e 's|-obs.*||')

erc unpack $TAR || fatal

cd * || fatal

mkdir -p usr/lib64/obs-plugins/
mkdir -p usr/share/obs/obs-plugins/obs-linuxbrowser/

install -Dm755 bin/64bit/* usr/lib64/obs-plugins/
cp -R data/* usr/share/obs/obs-plugins/obs-linuxbrowser/

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

return_tar $PKGNAME.tar
