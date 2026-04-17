#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# bundled Qt5, test and XML modules not bundled (optional)
ignore_lib_requires 'libQt5Test.so.*' 'libQt5XmlPatterns.so.*'

remove_file $PRODUCTDIR/libQt5QuickTest.*
remove_file $PRODUCTDIR/libQt5Declarative.*

