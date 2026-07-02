#!/bin/sh

# Repack Veeam Agent rpm for ALT.
# The upstream rpm ships RHEL-style package-name Requires (file-libs, fuse-libs,
# ncurses-libs) that ALT apt cannot resolve by name. Drop them and declare the
# real runtime libraries as soname Requires, which ALT resolves automatically.

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# drop RHEL package-name Requires ALT does not provide under these names
for r in file-libs fuse-libs ncurses-libs ; do
    subst "/^Requires:[[:space:]]*$r\$/d" $SPEC
done

# real system runtime libs veeam links against (veeam-libs bundles the rest)
add_unirequires "libmagic.so.1 libfuse.so.2 libncurses.so.6 libtinfo.so.6"
