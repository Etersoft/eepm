#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=obsidian
PRODUCTCUR=obsidian
PRODUCTDIR=/opt/Obsidian


. $(dirname $0)/common-chromium-browser.sh

cleanup

#add_bin_commands

if [ ! -f "$BUILDROOT/usr/bin/$PRODUCT" ] ; then
    add_bin_exec_command
fi

install_deps

fix_chrome_sandbox

fix_desktop_file

#epm assure patchelf || exit
#for i in $BUILDROOT$PRODUCTDIR/$PRODUCT ; do
#    a= patchelf --set-rpath "$PRODUCTDIR" $i
#done

set_autoreq 'yes'
