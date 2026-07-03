#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=sunshine

. $(dirname $0)/common.sh

add_conflicts sunshine

epm assure patchelf
epm assure ldd glibc-utils
epm assure rpm2cpio cpio

RPM_ARCH=$(epm print info -a)
FEDORA_RELEASE=$(basename "$4" | sed -n 's/.*\.fc\([0-9][0-9]*\)\..*/\1/p')
[ -n "$FEDORA_RELEASE" ] || fatal "Can't get Fedora release from $4"

SUNSHINE_LIBDIR=/usr/share/sunshine/lib

ICU_MAJOR=$(ldd "usr/bin/sunshine" | awk -F'.so.' '/libicu/{split($2,a," "); print a[1]; exit}')
[ -n "$ICU_MAJOR" ] || fatal "Can't detect ICU major version from sunshine binary"

KOJI="https://kojipkgs.fedoraproject.org/packages/icu"
ICU_VER=$(epm tool eget --list "$KOJI/" | grep -oE "${ICU_MAJOR}\.[0-9]+/$" | sort -V | tail -1 | sed 's|/$||')
[ -n "$ICU_VER" ] || fatal "Can't find ICU $ICU_MAJOR.x on koji"
ICU_REL=$(epm tool eget --list "$KOJI/$ICU_VER/" | grep -oE "[0-9]*\.fc${FEDORA_RELEASE}/" | sort -V | tail -1 | sed 's|/$||')
[ -n "$ICU_REL" ] || fatal "Can't find ICU $ICU_VER for fc$FEDORA_RELEASE"

tmpdir=$(mktemp -d) || fatal
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

epm tool eget -O "$tmpdir/libicu.rpm" "$KOJI/$ICU_VER/$ICU_REL/$RPM_ARCH/libicu-$ICU_VER-$ICU_REL.$RPM_ARCH.rpm" || fatal
mkdir -p "$tmpdir/fedora-icu"
( cd "$tmpdir/fedora-icu" && rpm2cpio "$tmpdir/libicu.rpm" | cpio -idm --quiet "./usr/lib64/libicudata.so.$ICU_MAJOR*" "./usr/lib64/libicuuc.so.$ICU_MAJOR*" 2>/dev/null ) || fatal "Can't extract libicu RPM"

mkdir -p "$BUILDROOT$SUNSHINE_LIBDIR" || fatal
pack_dir "$SUNSHINE_LIBDIR"
find "$tmpdir/fedora-icu" \( -type f -o -type l \) -name 'libicu*.so*' | sort -V | while read -r lib ; do
    dest="$SUNSHINE_LIBDIR/$(basename "$lib")"
    cp -a "$lib" "$BUILDROOT$dest" || fatal
    pack_file "$dest"
    [ -L "$BUILDROOT$dest" ] || chmod 0755 "$BUILDROOT$dest"
done

find "$BUILDROOT$SUNSHINE_LIBDIR" -type f -name 'libicu*.so*' | while read -r lib ; do
    a='' patchelf --set-rpath '$ORIGIN' "$lib" || fatal
done

a='' patchelf --set-rpath '$ORIGIN/../share/sunshine/lib' "usr/bin/sunshine"
a='' patchelf --replace-needed "libappindicator3.so.1" "libayatana-appindicator3.so.1" "usr/bin/sunshine"

fix_desktop_file "^Exec=.*" "Exec=sunshine"

# The binary has libminiupnpc in NEEDED, but does not import any symbols from it.
# Loading Fedora's libminiupnpc on ALT can crash at process start, so drop this unused entry.
patchelf --print-needed "usr/bin/sunshine" | grep '^libminiupnpc\.so\.' | while read -r lib ; do
    a='' patchelf --remove-needed "$lib" "usr/bin/sunshine" || fatal
done
