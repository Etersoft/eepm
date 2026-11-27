#!/bin/sh

FILENAME="$1"
RETURNTARNAME="$2"
PKGROOT="$PWD/1c83-client-root"
INSTALLTMP="$PWD/1c83-installer-tmp"

. $(dirname $0)/common.sh

# unpack if something like server64_8_3_22_1851.tar.gz
if echo "$(basename "$FILENAME")" | grep -q "^server.._8_3.*tar\.gz$" ; then
    echo "Tarball detected, unpacking ..."
    erc --here "$FILENAME" || fatal
    # server64_8_3_22_1851.tar
    FILENAME="$(echo server*/setup-full-8.*.run)"
fi

# with run with setup-full.*.run or setup-training.*.run file
case "$(basename "$FILENAME")" in
    setup-full-8.*-*.run|setup-training-8.*-*.run) ;;
    *) fatal "run with file looks like setup-full-8.3.22.1851-x86_64.run or setup-training-8.5.1.1150-x86_64.run" ;;
esac


case "$(basename "$FILENAME")" in
    setup-training-*) INSTDIR="/opt/1cv8t" ;;
    *) INSTDIR="/opt/1cv8" ;;
esac
VERSION="$(echo $FILENAME | sed 's|.*-8|8|' | sed 's|-.*||')"
TARNAME="1c83-client-$VERSION.tar"

epm assure bwrap bubblewrap || fatal
epm assure xdg-desktop-menu xdg-utils || fatal
mkdir -p "$PKGROOT$INSTDIR" "$PKGROOT/usr/share" "$INSTALLTMP" || fatal
installer="$(realpath "$FILENAME")" || fatal "Can't resolve $FILENAME"
# A symlink to the source can lead outside the pack directory, where the
# sandbox's mapped uid may not be able to traverse the parent directories.
case "$installer" in
    "$PWD"/*) stage_installer= ;;
    *) stage_installer=1 ;;
esac
if [ -n "$stage_installer" ] || [ ! -x "$installer" ] ; then
    staged_installer="$(mktemp "$PWD/1c83-installer.XXXXXX")" || fatal
    cp --reflink=auto "$installer" "$staged_installer" || fatal "Can't stage $FILENAME"
    installer="$staged_installer"
    chmod u+x "$installer" || fatal
fi

# --prefix does not isolate vendor scripts (and is absent in the 8.5 installer).
# Only payload and generated shared data persist; other host paths are read-only
# or private mounts. Never fall back to an unsandboxed privileged installer.
bwrap --unshare-all --uid 0 --gid 0 --die-with-parent --new-session \
    --ro-bind / / --ro-bind /proc /proc --dev /dev \
    --bind "$INSTALLTMP" /tmp --tmpfs /var/tmp --tmpfs /opt --tmpfs /usr/local \
    --bind "$PKGROOT$INSTDIR" "$INSTDIR" \
    --bind "$PKGROOT/usr/share" /usr/share \
    --ro-bind "$installer" /tmp/installer --chdir /tmp \
    --setenv HOME /tmp --setenv TMPDIR /tmp \
    /tmp/installer --mode unattended --unattendedmodeui none \
    --disable-components v8_install_deps,ws --enable-components desktop_icons || fatal "1C installer failed in the sandbox"

# Some installer versions use the per-user XDG paths even in unattended mode.
if [ -d "$INSTALLTMP/.local/share" ] ; then
    cp -a "$INSTALLTMP/.local/share/." "$PKGROOT/usr/share/"
fi

if echo "$FILENAME" | grep -q "x86_64.run$" ; then
    arch="x86_64"
elif echo "$FILENAME" | grep -q "i586.run$"; then
    arch="i586"
else
    fatal "Unsupported arch"
fi

[ -d "$PKGROOT$INSTDIR/$arch/$VERSION" ] || fatal "Can't detect installed 1C files in $PKGROOT$INSTDIR/$arch/$VERSION"

rm -rf "$PKGROOT$INSTDIR/conf" "$PKGROOT$INSTDIR/$arch/$VERSION/conf" || fatal

epm assure tar || fatal
( cd "$PKGROOT" && erc pack "../$TARNAME" opt usr ) || fatal

return_tar $TARNAME
