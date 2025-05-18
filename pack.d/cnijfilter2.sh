#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if ! echo "$TAR" | grep -q "cnijfilter2" ; then
    fatal "No idea how to handle $TAR"
fi

erc unpack $TAR && cd cni* || fatal

arch="$(epm print info -a)"

#PKG="packages/cnijfilter2_*_amd64.deb"
PKG="packages/cnijfilter2-*.$arch.rpm"

return_tar $PKG
