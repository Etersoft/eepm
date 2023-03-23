#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yandex-browser-stable-codecs-ffmpeg-extra

. $(dirname $0)/common.sh

add_requires yandex-browser-stable
