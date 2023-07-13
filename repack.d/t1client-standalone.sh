#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=t1client
PRODUCTDIR=/opt/dssl/t1client

. $(dirname $0)/common-chromium-browser.sh

subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

add_bin_link_command $PRODUCT $PRODUCTDIR/run_t1client.sh

fix_desktop_file /opt/dssl/t1client/run_t1client.sh $PRODUCT
