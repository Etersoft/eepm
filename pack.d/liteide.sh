#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME="$(basename "$TAR" | sed -e 's|liteidex|liteide-|')"
mv -v $TAR $PKGNAME

return_tar $PKGNAME
