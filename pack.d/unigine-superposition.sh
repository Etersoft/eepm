#!/bin/sh

TAR="$1"
#VERSION="$2"
RETURNTARNAME="$2"

OPKGNAME="Unigine_Superposition"

. $(dirname $0)/common.sh

# args: <run file> <output tar>
convert_makeself_to_tar()
{
    offset=`head -n 402 "$1" | wc -c | tr -d " "`
    dd if="$1" ibs=$offset skip=1 obs=1024 conv=sync | gzip -cd > "$2"
}

BASENAME="$(basename $TAR .run | tr "[A-Z_]" "[a-z-]")"

convert_makeself_to_tar $TAR $BASENAME.tar

return_tar $BASENAME.tar

