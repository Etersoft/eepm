#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if ! echo "$TAR" | grep -q "scanner-driver-avision.*.tar.gz.*" ; then
    fatal "Unknown file $TAR"
fi

erc $TAR || fatal

#rm $TAR

cd scanner-driver-avision* || fatal

PKG="scanner-driver-avision-*.x86_64.rpm"

return_tar $PKG
