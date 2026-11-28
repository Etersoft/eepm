#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=artipic
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# Version: 3.8.3-202609101919-prod-ru-astra-1.7 (build date, edition and target OS)
VERSION="$(grep '^Version:' $SPEC | sed -e 's|^Version:[[:space:]]*||' -e 's|_.*||')"
subst "s|^Version:.*|Version: $VERSION|" $SPEC
subst "s|^Release:.*|Release: epm1.repacked.1|" $SPEC

# AppImage leftovers in the root of the deb
remove_file /AppRun
remove_file /.DirIcon

move_to_opt /usr/local/artipic || fatal

# vendor wrappers run ../local/artipic/bin/run_*
remove_file /usr/bin/artipic
remove_file /usr/bin/apwatchdog
add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/run_artipic
add_bin_exec_command apwatchdog $PRODUCTDIR/bin/run_apwatchdog

# The vendor postinst runs it to sign the optional libmscl build downloaded in preinst
# (the download link is dead now), then removes it
remove_file $PRODUCTDIR/bin/binarysigner

# not used at runtime
remove_file $PRODUCTDIR/lib/libcryptopp.a
remove_file $PRODUCTDIR/lib/libssl.so.1.0.2
remove_file $PRODUCTDIR/lib/libcrypto.so.1.0.2
find $BUILDROOT$PRODUCTDIR -name '*.la' | while read -r f ; do
    remove_file "${f#$BUILDROOT}"
done

# bundled libtiff.so.5 needs libjbig.so.0 (Debian soname), bundled libheif needs libx265.so.165:
# they are used by ImageMagick coders and Qt image plugins only, use system libtiff.so.5 and libheif.so.1
remove_file $PRODUCTDIR/lib/libtiff.so.5
remove_file $PRODUCTDIR/lib/libtiff.so.5.5.0
remove_file $PRODUCTDIR/lib/libheif.so
remove_file $PRODUCTDIR/lib/libheif.so.1
remove_file $PRODUCTDIR/lib/libheif.so.1.5.0

# ImageMagick coders are linked with libjbig.so.0 (Debian soname of jbigkit 2.1),
# other distros ship the same library as libjbig.so.2.1
if ! is_soname_present libjbig.so.0 ; then
    epm assure patchelf || fatal
    find "$BUILDROOT$PRODUCTDIR" -type f -name '*.so*' | while read -r f ; do
        a='' patchelf --print-needed "$f" 2>/dev/null | grep -q '^libjbig\.so\.0$' || continue
        a='' patchelf --replace-needed libjbig.so.0 libjbig.so.2.1 "$f" || fatal
    done
fi

# the launcher calls killall to stop a running copy
add_unirequires /usr/bin/killall
