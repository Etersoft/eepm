#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. "$(dirname "$0")/common.sh"

modules=/usr/lib/kilo-desktop/resources/app.asar.unpacked/node_modules

# These musl prebuilds are unused on glibc and introduce unavailable RPM dependencies.
remove_file "$modules/@github/keytar/prebuilds/linuxmusl-*/keytar.node"
remove_file "$modules/@koromix/koffi-linux-*/musl_*/koffi.node"
remove_file "$modules/better-sqlite3/prebuilds/linuxmusl-*.node"
