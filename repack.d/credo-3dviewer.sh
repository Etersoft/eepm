#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=credo-3dviewer
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# upstream package is named credo-viewer and uses /opt/credo-viewer, the same as TIM CREDO VIEWER
subst "s|^Name:.*|Name: $PRODUCT|" $SPEC
move_dir /opt/credo-viewer $PRODUCTDIR

remove_file /usr/bin/credo_viewer
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/credo_viewer-runner
# desktop files still have the upstream path
fix_desktop_file /opt/credo-viewer/bin/credo_viewer-runner $PRODUCT

# from the upstream postinstall
printf '[General]\nCopyrightHolder=RU\n' | create_file "/etc/xdg/Credo-Dialogue/CREDO 3D Viewer.conf"
mark_config_noreplace "/etc/xdg/Credo-Dialogue/CREDO 3D Viewer.conf"
