#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

OPKGNAME="Unigine_Valley"

. $(dirname $0)/common.sh

BASENAME="$(basename $TAR .run | tr "[A-Z_]" "[a-z-]")"

erc repack $TAR $BASENAME.tar || fatal

cat <<EOF >$BASENAME.tar.eepm.yaml
name: $PRODUCT
group: Graphics
license: Proprietary
url: https://benchmark.unigine.com/valley
summary: Unigine Valley (Unigine Benchmark)
description: Unigine Valley (Unigine Benchmark).
EOF

return_tar $BASENAME.tar

