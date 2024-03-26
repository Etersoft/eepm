#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

move_to_opt

# used by libscram.so
ignore_lib_requires libcrypto.so.1.0.0
# used by libsasldb.so
ignore_lib_requires libdb-5.3.so

rm -v usr/bin/$PRODUCT
add_bin_link_command

#add_electron_deps
add_libs_requires

fix_chrome_sandbox
