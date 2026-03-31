#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if ! echo "$TAR" | grep -q "LinuxSoftware_i2000.*deb.tar.gz" ; then
    fatal "Unknow file $TAR"
fi

erc --here $TAR || fatal

PKG="kodak_i2000-*.amd64.deb"

return_tar $PKG
