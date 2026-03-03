#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=f3d
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# Move /usr to /opt/f3d (preserves internal structure: bin/, lib/, share/)
move_to_opt "/usr"

# Remove dev files (headers and cmake)
remove_dir $PRODUCTDIR/include
remove_dir $PRODUCTDIR/lib/cmake

# Restore desktop files
for f in $BUILDROOT$PRODUCTDIR/share/applications/*.desktop ; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    install_file $PRODUCTDIR/share/applications/$name /usr/share/applications/$name
done
remove_dir $PRODUCTDIR/share/applications

# Restore icons
for size in 16x16 24x24 32x32 48x48 64x64 256x256 scalable ; do
    for ext in png svg ; do
        src="$PRODUCTDIR/share/icons/hicolor/$size/apps/f3d.$ext"
        [ -f "$BUILDROOT$src" ] || continue
        install_file "$src" "/usr/share/icons/hicolor/$size/apps/f3d.$ext"
    done
done
if [ -f "$BUILDROOT$PRODUCTDIR/share/icons/HighContrast/scalable/apps/f3d.svg" ] ; then
    install_file "$PRODUCTDIR/share/icons/HighContrast/scalable/apps/f3d.svg" "/usr/share/icons/HighContrast/scalable/apps/f3d.svg"
fi
remove_dir $PRODUCTDIR/share/icons

# Restore mime types
for f in $BUILDROOT$PRODUCTDIR/share/mime/packages/*.xml ; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    install_file $PRODUCTDIR/share/mime/packages/$name /usr/share/mime/packages/$name
done
remove_dir $PRODUCTDIR/share/mime

# Restore metainfo
for f in $BUILDROOT$PRODUCTDIR/share/metainfo/*.xml ; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    install_file $PRODUCTDIR/share/metainfo/$name /usr/share/metainfo/$name
done
remove_dir $PRODUCTDIR/share/metainfo

# Restore thumbnailers
for f in $BUILDROOT$PRODUCTDIR/share/thumbnailers/*.thumbnailer ; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    install_file $PRODUCTDIR/share/thumbnailers/$name /usr/share/thumbnailers/$name
done
remove_dir $PRODUCTDIR/share/thumbnailers

# Restore man page
if [ -f "$BUILDROOT$PRODUCTDIR/share/man/man1/f3d.1.gz" ] ; then
    install_file $PRODUCTDIR/share/man/man1/f3d.1.gz /usr/share/man/man1/f3d.1.gz
    remove_dir $PRODUCTDIR/share/man
fi

# Create /usr/bin/f3d wrapper
add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT

# Fix desktop file Exec path
fix_desktop_file $PRODUCTDIR/bin/$PRODUCT $PRODUCT

# Add library dependencies from the binary
ignore_lib_requires "libblosc.so.1" "libf3d.so.3" "libf3d_c_api.so" "libtbb.so.12" "libusd_ms.so"
add_libs_requires
