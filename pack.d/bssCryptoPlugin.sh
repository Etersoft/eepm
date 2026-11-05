#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# makeself archive extracts files into current directory (no subdirectory)
erc --here unpack "$TAR" || fatal

[ -s bssCryptoPlugin.deb ] || fatal "Can't find bssCryptoPlugin.deb in $TAR"

return_tar bssCryptoPlugin.deb
