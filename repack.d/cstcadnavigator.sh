#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTCUR=cstCadNavigator
. $(dirname $0)/common.sh

move_to_opt

# TODO: fix bug in upstream
remove_file /usr/bin/libfmux.so
remove_file /usr/bin/libdynapdf.so

find . -type f -exec chmod 0644 {} +

add_bin_exec_command $PRODUCTCUR
add_bin_link_command $PRODUCT $PRODUCTCUR

cat <<EOF >>./usr/share/applications/$PRODUCT.desktop
MimeType=image/vnd.dwg;model/stl;image/cgm;image/svg+xml;
EOF

