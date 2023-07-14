#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vivaldi-stable-codecs-ffmpeg-extra

. $(dirname $0)/common.sh

add_requires vivaldi-stable

set_autoreq 'yes'
