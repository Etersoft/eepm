#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if ! echo "$TAR" | grep -q "epsonscan2-bundle-.*.tar.gz" ; then
    fatal "No idea how to handle $TAR"
fi

erc --here unpack $TAR || fatal
cd "$(erc basename $TAR)" || fatal

# TODO:
# cp $base/DefaultSettings.SF2 $HOME/.epsonscan2

core="core/epsonscan2*.*"

return_tar $core
