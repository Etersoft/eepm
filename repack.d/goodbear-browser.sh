#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=goodbear

. $(dirname $0)/common-chromium-browser.sh

set_alt_alternatives 65
