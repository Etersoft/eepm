#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_libs_requires

add_unirequires "typelib(AyatanaAppIndicator3)"

# TODO: remove this hack
if ! epm installed 'yandex-disk' ; then
    epm play yandex-disk
fi
