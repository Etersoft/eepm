#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

epm install --skip-installed glib2 libatk libcairo libcairo-gobject libcups libgdk-pixbuf libgio libgtk+3 libpango libxml2 libjbig
