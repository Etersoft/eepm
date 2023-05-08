#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# Oracle_VM_VirtualBox_Extension_Pack-$VERSION.vbox-extpack
BASENAME=$(basename $TAR .vbox-extpack)
VERSION=$(echo $BASENAME | sed -e 's|.*-||')
BASENAME="Oracle_VM_VirtualBox_Extension_Pack"
ln -s $TAR $BASENAME.tgz
erc unpack $BASENAME.tgz || fatal

rm -rv $BASENAME/{darwin.amd64,solaris.amd64,win.amd64}

mkdir -p usr/lib64/virtualbox/ExtensionPacks/
mv $BASENAME usr/lib64/virtualbox/ExtensionPacks/

PKGNAME=$PRODUCT-$VERSION
erc pack $PKGNAME.tar usr/lib64/virtualbox/ExtensionPacks/$BASENAME || fatal

return_tar $PKGNAME.tar
