#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

UNIREQUIRES="yt-dlp"

. $(dirname $0)/common.sh
