#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

ignore_lib_requires 'libicudata.so.46()(64bit)' 'libicui18n.so.46()(64bit)' 'libicuuc.so.46()(64bit)' 'libnghttp2-v8.so.14()(64bit)'
add_requires 'libicudata.so.74' 'libwebkit2gtk-4.1.so.0' 'libjavascriptcoregtk-4.0.so.18'

add_libs_requires 
