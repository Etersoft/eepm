#!/bin/sh

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# Stream Tube loads the player library at runtime.
add_unirequires libmpv.so.2
