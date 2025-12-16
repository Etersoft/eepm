#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT

fix_desktop_file /opt/ocenaudio/bin/ocenaudio $PRODUCT

if ! is_soname_present libbz2.so.1.0 ; then
    # fIXME: https://bugzilla.altlinux.org/35320
    ignore_lib_requires 'libbz2.so.1.0'
    is_soname_present libbz2.so.1 || fatal "Can't find libbz2.so.1"
    ln -s -v $(get_path_by_soname "libbz2.so.1") .$PRODUCTDIR/lib/libbz2.so.1.0
    pack_file $PRODUCTDIR/lib/libbz2.so.1.0
    add_unirequires libbz2.so.1
fi

case "$(epm print info -e)" in
    ALTLinux/p10|Debian/11*)
        # Application depends on external Qt5 libraries
        add_unirequires libQt5Concurrent.so.5 libQt5Core.so.5 libQt5Gui.so.5 libQt5Network.so.5 libQt5Widgets.so.5
        ;;
    *)
        add_unirequires libQt6Concurrent.so.6 libQt6Core.so.6 libQt6Gui.so.6 libQt6Network.so.6 libQt6Widgets.so.6
esac

add_libs_requires

