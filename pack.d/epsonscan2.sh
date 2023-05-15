#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if ! echo "$TAR" | grep -q "epsonscan2-bundle-.*.tar.gz" ; then
    fatal "No idea how to handle $TAR"
fi

erc unpack $TAR && cd epsonscan2-bundle-* || fatal

pkgtype="$(epm print info -p)"

core="core/epsonscan2*.*"
plugins="plugins/epsonscan2-non-free-plugin*.*"

return_tar $core $plugins
