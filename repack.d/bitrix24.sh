#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=bitrix24

UNIREQUIRES='libnotify.so.4'

. $(dirname $0)/common.sh

