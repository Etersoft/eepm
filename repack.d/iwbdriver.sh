#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=IWB_Driver
ICONFILE=ibw-driver.png

. $(dirname $0)/common.sh

move_to_opt /usr/bin/IWB_Driver
subst "s|/usr/bin/IWB_Driver/run.sh|ibw-driver|" $BUILDROOT/usr/share/applications/iwb-driver.desktop
subst "s|/usr/bin/IWB_Driver/icon.png|$ICONFILE|" $BUILDROOT/usr/share/applications/iwb-driver.desktop
add_bin_exec_command ibw-driver $PRODUCTDIR/$PRODUCT

# obsoleted
remove_file $PRODUCTDIR/IWB_Driver.sh
remove_file $PRODUCTDIR/run.sh
remove_file $PRODUCTDIR/sudo.sh~

cd $BUILDROOT$PRODUCTDIR/

chmod -R a+rX .

install_file $PRODUCTDIR/icon.png /usr/share/pixmaps/$ICONFILE

epm assure patchelf || exit
for i in IWB_Driver libQt*.so.* ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done
