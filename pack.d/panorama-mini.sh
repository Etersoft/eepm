#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# zip archive contains the package with readme.txt and license.txt
erc --here unpack "$TAR" || fatal

for i in *.rpm *.deb ; do
    [ -s "$i" ] && return_tar "$i"
done

fatal "Can't find a package in $TAR"
