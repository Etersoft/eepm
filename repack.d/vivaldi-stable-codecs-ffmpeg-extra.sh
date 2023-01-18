#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vivaldi-stable-codecs-ffmpeg-extra

subst '1iRequires:vivaldi-stable' $SPEC
