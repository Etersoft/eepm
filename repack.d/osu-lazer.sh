#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

remove_file /opt/osu-lazer/usr/bin/UpdateNix

stop_libs_requires
