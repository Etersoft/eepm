#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PREINSTALL_PACKAGES="glib2 libdbus libEGL fontconfig libfreetype libGL libGLU libICE libjasper libSM libX11 libxcb libXext libXi libXrender zlib"

. $(dirname $0)/common.sh

move_to_opt "/opt/lithium*" || fatal "can't move to $PRODUCTDIR"

add_bin_link_command $PRODUCT $PRODUCTDIR/launcher.sh

#subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

cd $BUILDROOT$PRODUCTDIR || fatal
if epm assure patchelf ; then
for i in bin/{launcher,libraryCreator,projectCreator} ; do
    a= patchelf --set-rpath '$ORIGIN' $i || continue
done
for i in bin/{*.so,*.so.*} ; do
    a= patchelf --set-rpath '$ORIGIN' $i || continue
done
for i in bin/plugins/*/*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../../' $i || continue
done
fi

# missed with other soname
ln -s /usr/lib64/libjasper.so.4 bin/libjasper.so.1
pack_file $PRODUCTDIR/bin/libjasper.so.1

install_file lithium-ecad.desktop /usr/share/applications/$PRODUCT.desktop
fix_desktop_file "/opt/lithium_ecad-.*/launcher.sh" $PRODUCT
fix_desktop_file "/opt/lithium_ecad-.*/lithium-ecad.png" $PRODUCT

install_file lithium-ecad.png /usr/share/pixmaps/$PRODUCT.png
