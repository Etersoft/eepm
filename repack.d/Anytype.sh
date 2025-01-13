#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

ignore_lib_requires 'libpython3.11.so.1.0'
add_chromium_deps
add_libs_requires
fix_chrome_sandbox