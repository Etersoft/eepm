#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# PySide6 QtGraphs/QtGraphsWidgets not available on older distros
ignore_lib_requires libQt6Graphs.so.6
ignore_lib_requires libQt6GraphsWidgets.so.6
