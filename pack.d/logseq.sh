#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME="$(basename "$TAR" | sed -e "s|^Logseq-linux-x64-|logseq-|" )"
mv -v $TAR $PKGNAME

return_tar $PKGNAME
