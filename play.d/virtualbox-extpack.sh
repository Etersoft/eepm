#!/bin/sh

PKGNAME=
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION='Oracle VM VirtualBox Extension pack from the official site (personal use only)'

case "$1" in
    "--remove")
        esu VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"
        exit
        ;;
esac

. $(dirname $0)/common.sh

#if [ "$VERSION" = "*" ] ; then
#    VERSION=$(basename $(eget --list --latest https://download.virtualbox.org/virtualbox/ "^[0-9]*"))
#fi

# for current virtualbox package
if [ "$VERSION" = "*" ] ; then
    VERSION="$(epm print version for package virtualbox)"
fi

PACKURL="https://download.virtualbox.org/virtualbox/$VERSION/Oracle_VM_VirtualBox_Extension_Pack-$VERSION.vbox-extpack"

# cd to tmp dir
PKGDIR=$(mktemp -d)
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

eget $PACKURL || exit

esu VBoxManage extpack install $(pwd)/*.vbox-extpack
