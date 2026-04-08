#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=aimp
PRODUCTDIR=/opt/aimp

. $(dirname $0)/common.sh

# wine version has aimp.bash, native does not
if [ -f "$BUILDROOT$PRODUCTDIR/aimp.bash" ] ; then
    subst "s|^Name:.*|Name: aimp-wine|" $SPEC
    add_conflicts aimp
    add_requires '/usr/bin/wine'
    add_requires '/bin/sh'
    add_bin_link_command aimp-wine $PRODUCTDIR/aimp.bash
    subst "s|/usr/bin/sh|/bin/sh|" $BUILDROOT$PRODUCTDIR/aimp.bash
    install_file /opt/aimp/aimp.desktop /usr/share/applications/aimp.desktop
    fix_desktop_file /opt/aimp/aimp.bash aimp-wine
else
    add_conflicts aimp-wine
fi
