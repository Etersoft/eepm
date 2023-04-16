#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=kubo

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: File tools|" $SPEC
subst "s|^License:.*$|License: MIT/Apache-2.0|" $SPEC
subst "s|^URL:.*|URL: https://github.com/ipfs/kubo|" $SPEC
subst "s|^Summary:.*|Summary: An IPFS implementation in Go|" $SPEC


subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

subst '1iConflicts: go-ipfs' $SPEC
subst '1iProvides: go-ipfs' $SPEC


