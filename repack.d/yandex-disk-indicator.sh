#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_conflicts yandex-disk-indicator
add_provides "yandex-disk-indicator = %version"

add_libs_requires

add_unirequires "typelib(AyatanaAppIndicator3)"

if ! epm qa | grep 'yandex-disk' | grep -v 'indicator' ; then
    epm play yandex-disk
fi
