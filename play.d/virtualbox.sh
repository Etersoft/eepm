#!/bin/sh

PKGNAME=virtualbox
SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION='VirtualBox from the ALT repo'

. $(dirname $0)/common.sh

vendor="$(epm print info -s)"
arch="$(epm print info -a)"

epm install $PKGNAME || exit

#if [ "$USER" != "root" ] ; then
#    echo "Adding user $USER to vboxusers group:"
#    echo "\$ $SUDO usermod -a -G vboxusers $USER"
#    $SUDO usermod -a -G vboxusers $USER
#fi

#[ "$vendor" != "alt" ] && exit

epm install kernel-module-virtualbox || exit

echo
echo "Note:Add needed users to vboxusers group via # usermod -a -G vboxusers <user>"
echo "If the kernel just updated, you need reboot the system before VirtualBox using."
