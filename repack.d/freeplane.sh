#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

move_to_opt
ln -sf $PRODUCTDIR/$PRODUCT.sh usr/bin/$PRODUCT
fix_desktop_file "/usr/bin/freeplane/$PRODUCT"

remove_dir /usr/lib/mime

add_requires java-openjdk
