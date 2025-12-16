#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if ! echo "$TAR" | grep -q "LinuxSoftware_i11xx.*deb.tar.gz" ; then
    fatal "Unknow file $TAR"
fi

erc $TAR || fatal

#rm $TAR
cd LinuxSoftware* || fatal

PKG="kodak_i11xx-*.amd64.deb"

return_tar $PKG
