#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Viber
PRODUCTCUR=viber
PRODUCTDIR=/opt/viber

. $(dirname $0)/common.sh

# handle AppImage
if [ -f ".$PRODUCTDIR/.DirIcon" ] ; then
    ignore_lib_requires libQt6LabsSettings.so.6 libQt6LabsSharedImage.so.6 libQt6LabsWavefrontMesh.so.6 libQt6WebEngineQuickDelegatesQml.so.6 libQt6LabsQmlModels.so.6
    add_libs_requires
    exit
fi

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

# hack, todo: update libevent in p10
get_libevent()
{
    local libdir
    for libdir in /usr/lib/x86_64-linux-gnu /usr/lib64 /lib64 ; do
        basename $(ls $libdir/libevent-2.1.so.[0-9] 2>/dev/null) 2>/dev/null
    done | head -n1
}

libevent="$(get_libevent)"
[ -n "$libevent" ] || fatal "libevent is missed, install it before"

if [ "$libevent" != "libevent-2.1.so.7" ] && epm assure patchelf ; then
    patchelf --replace-needed libevent-2.1.so.7 $libevent .$PRODUCTDIR/lib/libQt6WebEngineCore.so.6
fi


fix_desktop_file

add_libs_requires
