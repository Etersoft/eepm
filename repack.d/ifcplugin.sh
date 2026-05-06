#!/bin/sh
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# libcrypt32.so is a CryptoPro library shipped via ITCS (not in any repo),
# loaded together with CryptoPro by /usr/lib/mozilla/plugins/lib/libcapi_engine_linux.so
ignore_lib_requires libcrypt32.so
