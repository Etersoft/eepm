#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=credo-viewer
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/bin/Viewer
fix_desktop_file $PRODUCTDIR/bin/Viewer $PRODUCT

# from the upstream posttrans: CREDO products register themselves in this list
echo 'КРЕДО ИМ=Credo-III' | create_file /etc/Credo-Dialogue/Products/Credo-III/ProductsList
mark_config_noreplace /etc/Credo-Dialogue/Products/Credo-III/ProductsList
