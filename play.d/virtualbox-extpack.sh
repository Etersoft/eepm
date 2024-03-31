#!/bin/sh

PKGNAME=virtualbox-extpack
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Oracle VM VirtualBox Extension pack from the official site (personal use only)'
URL="https://www.virtualbox.org/wiki/Downloads"

. $(dirname $0)/common.sh

#if [ "$VERSION" = "*" ] ; then
#    VERSION=$(basename $(eget --list --latest https://download.virtualbox.org/virtualbox/ "^[0-9]*"))
#fi

epm installed virtualbox || fatal "virtualbox package is not installed"

# for current virtualbox package
if [ "$VERSION" = "*" ] ; then
    VERSION="$(epm print version for package virtualbox)"
fi

PKGURL="https://download.virtualbox.org/virtualbox/$VERSION/Oracle_VM_VirtualBox_Extension_Pack-$VERSION.vbox-extpack"

install_pack_pkgurl
