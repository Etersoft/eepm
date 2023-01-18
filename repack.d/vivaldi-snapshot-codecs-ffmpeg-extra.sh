#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vivaldi-snapshot-codecs-ffmpeg-extra

subst '1iRequires:vivaldi-snapshot' $SPEC
