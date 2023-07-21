#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/pgadmin4

UNIREQUIRES="python3 libkrb5.so.3 libpq.so.5"

. $(dirname $0)/common.sh

move_to_opt /usr/pgadmin4

