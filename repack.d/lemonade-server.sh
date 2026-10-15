#!/bin/sh -x
# Repack lemonade-server.
#
# Keep the application payload under /opt/lemonade and expose its commands and
# integration files at the standard /usr locations. Non-Fedora packages keep
# the complete RPM payload, but use the portable embeddable server binaries.

BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/lemonade

. $(dirname $0)/common.sh

# Make the library available to dh_shlibdeps so converted DEB packages get
# the matching libdrm-amdgpu1 dependency.
if [ "$(epm print info -p)" = "deb" ] ; then
    epm install --skip-installed libdrm-amdgpu1
fi
add_unirequires libdrm_amdgpu.so.1

# 1. Consolidate the application payload under /opt/lemonade.
mkdir -p "$BUILDROOT$PRODUCTDIR"
mv "$BUILDROOT/opt/bin" "$BUILDROOT$PRODUCTDIR/bin"
mv "$BUILDROOT/opt/lib" "$BUILDROOT$PRODUCTDIR/lib"
mv "$BUILDROOT/opt/share" "$BUILDROOT$PRODUCTDIR/share"

# 2. Repoint the upstream integration symlinks to the consolidated payload.
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

# The upstream RPM registers this file from its install scripts. Repacking
# drops those scripts, so expose it at the standard path for the RPM trigger.
mkdir -p "$BUILDROOT/usr/lib/sysusers.d"
ln -snf "$PRODUCTDIR/lib/sysusers.d/lemonade.conf" \
    "$BUILDROOT/usr/lib/sysusers.d/lemonade.conf"
pack_file /usr/lib/sysusers.d/lemonade.conf

# 3. Keep resources next to the server binaries where Lemonade looks for them.
ln -snf ../share/lemonade-server/resources "$BUILDROOT$PRODUCTDIR/bin/resources"
pack_file $PRODUCTDIR/bin/resources

# 4. Repoint the system service to the consolidated payload.
u="$BUILDROOT$PRODUCTDIR/lib/systemd/system/lemond.service"
[ -f "$u" ] && subst "s|^ExecStart=/opt/bin/lemond|ExecStart=$PRODUCTDIR/bin/lemond|" "$u"

# 5. Rewrite generated package paths to the consolidated payload.
subst 's|"/opt/|"/opt/lemonade/|g' $SPEC
pack_dir $PRODUCTDIR
