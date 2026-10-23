#!/bin/sh -x
# Repack lemonade-server.
#
# Keep the application payload under /opt/lemonade for every package path and
# expose its commands and integration files at the standard /usr locations.
# The upstream Fedora RPM needs /opt/{bin,lib,share} consolidated and its
# existing symlinks and system service repointed. The embeddable build is
# packed directly under /opt/lemonade and only needs command links in /usr/bin.

BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/lemonade

. $(dirname $0)/common.sh

if [ -d "$BUILDROOT$PRODUCTDIR" ] ; then
    add_bin_link_command lemonade $PRODUCTDIR/lemonade
    add_bin_link_command lemond $PRODUCTDIR/lemond
    exit
fi

# Fedora RPM layout.
mkdir -p "$BUILDROOT$PRODUCTDIR"
mv "$BUILDROOT/opt/bin" "$BUILDROOT$PRODUCTDIR/bin"
mv "$BUILDROOT/opt/lib" "$BUILDROOT$PRODUCTDIR/lib"
mv "$BUILDROOT/opt/share" "$BUILDROOT$PRODUCTDIR/share"

for l in \
    "$BUILDROOT/usr/bin/lemonade" \
    "$BUILDROOT/usr/bin/lemonade-web-app" \
    "$BUILDROOT/usr/lib/systemd/system/lemond.service" \
    "$BUILDROOT/usr/lib/systemd/user/lemond.service" \
    "$BUILDROOT/usr/share/applications/lemonade-web-app.desktop" \
    "$BUILDROOT/usr/share/pixmaps/lemonade-app.svg" ; do
    [ -L "$l" ] || continue
    target="$(readlink "$l")"
    case "$target" in
        /opt/*) ln -snf "$(echo "$target" | sed "s|^/opt/|$PRODUCTDIR/|")" "$l" ;;
    esac
done

ln -snf ../share/lemonade-server/resources "$BUILDROOT$PRODUCTDIR/bin/resources"
pack_file $PRODUCTDIR/bin/resources

u="$BUILDROOT$PRODUCTDIR/lib/systemd/system/lemond.service"
[ -f "$u" ] && subst "s|^ExecStart=/opt/bin/lemond|ExecStart=$PRODUCTDIR/bin/lemond|" "$u"

subst 's|"/opt/|"/opt/lemonade/|g' $SPEC
pack_dir $PRODUCTDIR
