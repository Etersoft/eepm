#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# Oracle_VM_VirtualBox_Extension_Pack-$VERSION.vbox-extpack (< 7.1.0)
# Oracle_VirtualBox_Extension_Pack-$VERSION.vbox-extpack (>= 7.1.0)
BASENAME=$(basename $TAR .vbox-extpack)
VERSION=$(echo $BASENAME | sed -e 's|.*-||')
BASENAME=$(echo $BASENAME | sed -e 's|-[^-]*$||')
ln -s $TAR $BASENAME.tgz
erc -C usr/lib64/virtualbox/ExtensionPacks/$BASENAME unpack $BASENAME.tgz || fatal

rm -rv usr/lib64/virtualbox/ExtensionPacks/$BASENAME/{darwin.amd64,solaris.amd64,win.amd64}

PKGNAME=$PRODUCT-$VERSION
erc pack $PKGNAME.tar usr/lib64/virtualbox/ExtensionPacks/$BASENAME || fatal

return_tar $PKGNAME.tar
