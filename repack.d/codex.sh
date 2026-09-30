#!/bin/sh

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PKGNAME="$3"

PRODUCT=codex
PRODUCTALT="codex codex-preview codex-voice"

. $(dirname $0)/common.sh

for i in $PRODUCTALT ; do
    [ "$i" = "$PKGNAME" ] && continue
    add_conflicts $i
done
