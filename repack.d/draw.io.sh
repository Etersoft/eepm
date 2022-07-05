#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=draw.io
PRODUCTDIR=/opt/drawio/

. $(dirname $0)/common-chromium-browser.sh

fix_chrome_sandbox
