#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

OPKGNAME="Unigine_Superposition"

. $(dirname $0)/common.sh

BASENAME="$(basename $TAR .run | tr "[A-Z_]" "[a-z-]")"

erc repack $TAR $BASENAME.tar || fatal

cat <<EOF >$BASENAME.tar.eepm.yaml
name: $PRODUCT
group: Graphics
license: Proprietary
url: https://benchmark.unigine.com/superposition
summary: Unigine Heaven (Unigine Benchmark)
description: Unigine Superposition (Unigine Benchmark).
EOF

return_tar $BASENAME.tar

