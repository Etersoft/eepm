#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=pantum-r

. $(dirname $0)/common.sh

# pantum-r and pantum share ~69 files (e.g. /etc/sane.d/dll.d/pantum6500)
add_conflicts pantum

if [ -d "$BUILDROOT/usr/lib/sane" ] ; then
    mkdir -p "$BUILDROOT/usr/lib64/sane"
    for f in "$BUILDROOT/usr/lib/sane/"* ; do
        [ -e "$f" ] || continue
        name="$(basename "$f")"
        move_file "/usr/lib/sane/$name" "/usr/lib64/sane/$name"
    done
    remove_dir /usr/lib/sane
fi

# Debian style duplicates (x86_64-linux-gnu and i386-linux-gnu handled by generic.sh)
remove_dir /usr/lib/aarch64-linux-gnu
remove_dir /usr/lib/arm-linux-gnueabihf

# duplicates main files
remove_dir /usr/local
