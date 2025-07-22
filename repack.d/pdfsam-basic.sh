#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

chmod a+x $BUILDROOT/opt/pdfsam-basic/runtime/bin/java
