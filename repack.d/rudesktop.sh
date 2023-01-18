#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

filter_from_requires "python3(AppKit)" "python3(CoreFoundation)" "python3(HIServices)" "python3(Quartz)" "python3(objc)"

epm install --skip-installed glib2 libcairo libgdk-pixbuf libgtk+3 libpango libpulseaudio libuuid libX11 libxcb libXfixes libXtst python3 python3-base python3-module-evdev python3-module-six xdotool
