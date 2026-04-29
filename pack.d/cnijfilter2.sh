#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if ! echo "$TAR" | grep -q "cnijfilter2" ; then
    fatal "No idea how to handle $TAR"
fi

erc --here unpack "$TAR" || fatal

arch="$(epm print info -a)"

#PKG="packages/cnijfilter2_*_amd64.deb"
PKG="cnijfilter2-*-rpm/packages/cnijfilter2-*.$arch.rpm"

return_tar $PKG
