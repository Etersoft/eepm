#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=djv
PRODUCTCUR=DVJ2
PRODUCTDIR=/opt/DVJ2

# install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
PREINSTALL_PACKAGES="libalsa libGLX libOpenGL libX11 libxcb libXext zlib"

. $(dirname $0)/common.sh

move_to_opt /usr/local/DJV2

set_autoreq 'yes'

rm -v $BUILDROOT/usr/bin/djv

add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT
add_bin_link_command $PRODUCTCUR $PRODUCT

fix_desktop_file /usr/local/DJV2/bin/djv.sh $PRODUCT

remove_file $PRODUCTDIR/etc/Color/nuke-default/make.py
remove_file $PRODUCTDIR/etc/Color/spi-anim/makeconfig_anim.py
remove_file $PRODUCTDIR/etc/Color/spi-vfx/make_vfx_ocio.py

if epm assure patchelf ; then
for i in $BUILDROOT$PRODUCTDIR/bin/{djv,djv_*} ; do
    a= patchelf --set-rpath '$ORIGIN/../lib' $i
done

for i in $BUILDROOT$PRODUCTDIR/lib/lib*.so* ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done
fi

filter_from_requires libav libswresample libswscale
