#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=pgadmin4
PRODUCTDIR=/opt/pgadmin4

. $(dirname $0)/common.sh

move_to_opt /usr/pgadmin4

VERSION=$(grep "^Version:" $SPEC | sed -e "s|Version: ||")

add_requires xdg-utils libatomic.so.1
add_requires pgadmin4-server = $VERSION

fix_desktop_file /usr/pgadmin4/bin/pgadmin4

add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT

add_libs_requires
