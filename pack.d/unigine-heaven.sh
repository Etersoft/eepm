#!/bin/sh

TAR="$1"
#VERSION="$2"
RETURNTARNAME="$2"

OPKGNAME="Unigine_Heaven"

. $(dirname $0)/common.sh

BASENAME="$(basename $TAR .run | tr "[A-Z_]" "[a-z-]")"

erc repack $TAR $BASENAME.tar || fatal

cat <<EOF >$BASENAME.tar.eepm.yaml
name: $PRODUCT
group: Graphics
license: Proprietary
url: https://benchmark.unigine.com/heaven
summary: Unigine Heaven (Unigine Benchmark)
description: Unigine Heaven (Unigine Benchmark).
EOF

return_tar $BASENAME.tar
