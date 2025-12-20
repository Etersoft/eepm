#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vk-messenger
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh


add_electron_deps

