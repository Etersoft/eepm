#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=djv
PRODUCTCUR=DVJ2
PRODUCTDIR=/opt/DVJ2

. $(dirname $0)/common.sh

move_to_opt /usr/local/DJV2

subst '1iAutoProv:no' $SPEC

rm -v $BUILDROOT/usr/bin/djv

add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT
add_bin_link_command $PRODUCTCUR $PRODUCT

fix_desktop_file /usr/local/DJV2/bin/djv.sh $PRODUCT

remove_file $PRODUCTDIR/etc/Color/nuke-default/make.py
remove_file $PRODUCTDIR/etc/Color/spi-anim/makeconfig_anim.py
remove_file $PRODUCTDIR/etc/Color/spi-vfx/make_vfx_ocio.py

epm assure patchelf || exit
for i in $BUILDROOT$PRODUCTDIR/bin/{djv,djv_*} ; do
    a= patchelf --set-rpath '$ORIGIN/../lib' $i
done

for i in $BUILDROOT$PRODUCTDIR/lib/lib*.so* ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done

filter_from_requires libav libswresample libswscale

# install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
epm install --skip-installed libalsa libGLX libOpenGL libX11 libxcb libXext zlib

