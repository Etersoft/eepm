#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

# Conflicts with an official client used before
add_conflicts yandex-music

add_libs_requires

fix_chrome_sandbox

add_electron_deps
