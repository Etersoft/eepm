#!/bin/sh -x
# Repack lemonade-server.
#
# The upstream RPM keeps its whole payload directly under /opt (/opt/bin,
# /opt/lib, /opt/share) and exposes it at the standard /usr locations through
# symlinks (e.g. /usr/lib/systemd/system/lemond.service -> /opt/lib/...,
# /usr/bin/lemonade -> /opt/bin/lemonade). That works, but pollutes /opt.
#
# Consolidate the payload under /opt/lemonade and repoint the existing /usr
# symlinks (and the unit's ExecStart) at it. The DEB already installs to /usr,
# so this only touches the RPM build.

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

PRODUCTDIR=/opt/lemonade

# DEB layout — already FHS-compliant.
[ -d "$BUILDROOT/opt/bin" ] || exit 0

# 1. Move the payload /opt/{bin,lib,share} -> /opt/lemonade/
mkdir -p "$BUILDROOT$PRODUCTDIR"
mv "$BUILDROOT/opt/bin"   "$BUILDROOT$PRODUCTDIR/bin"
mv "$BUILDROOT/opt/lib"   "$BUILDROOT$PRODUCTDIR/lib"
mv "$BUILDROOT/opt/share" "$BUILDROOT$PRODUCTDIR/share"

# 2. Repoint the /usr/* symlinks the package ships at /opt/lemonade/*
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

# 3. lemond resolves its resources relative to the binary (<exe>/resources);
#    point bin/resources at the shared resource tree.
ln -snf ../share/lemonade-server/resources "$BUILDROOT$PRODUCTDIR/bin/resources"
pack_file $PRODUCTDIR/bin/resources

# 4. Patch ExecStart in the system unit (now under /opt/lemonade/lib).
u="$BUILDROOT$PRODUCTDIR/lib/systemd/system/lemond.service"
[ -f "$u" ] && subst "s|^ExecStart=/opt/bin/lemond|ExecStart=$PRODUCTDIR/bin/lemond|" "$u"

# 5. Rewrite %files: every quoted /opt/ path becomes /opt/lemonade/.
subst 's|"/opt/|"/opt/lemonade/|g' $SPEC
pack_dir $PRODUCTDIR
