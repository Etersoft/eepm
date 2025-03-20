#!/bin/sh

PKGNAME=virtualbox-extpack
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Oracle VM VirtualBox Extension pack from the official site (personal use only)'
URL="https://www.virtualbox.org/wiki/Downloads"

. $(dirname $0)/common.sh

# for current virtualbox package
if [ "$VERSION" = "*" ] ; then
    if [ -n "$force" ] ; then
        VERSION=$(basename $(eget --list --latest https://download.virtualbox.org/virtualbox/ "^[0-9]*"))
    else
        epm installed virtualbox || fatal "virtualbox package is not installed"
        VERSION="$(epm print version for package virtualbox)"
    fi
fi

if [ "$(epm print compare "$VERSION" 7.1.0)" != "-1" ] ; then
    pkgname="Oracle_VirtualBox_Extension_Pack"
else
    pkgname="Oracle_VM_VirtualBox_Extension_Pack"
fi


PKGURL="https://download.virtualbox.org/virtualbox/$VERSION/$pkgname-$VERSION.vbox-extpack"

install_pack_pkgurl
