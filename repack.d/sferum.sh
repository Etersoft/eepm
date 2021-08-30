#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

mkdir -p $BUILDROOT/usr/bin/


# Link to the binary
ln -s /opt/Sferum/sferum $BUILDROOT/usr/bin/sferum


# Set SUID for chrome-sandbox if userns_clone is not supported
userns_path='/proc/sys/kernel/unprivileged_userns_clone'
userns_val="$(cat $userns_path 2>/dev/null)"
[ "$userns_val" = '1' ] || chmod 4755 $BUILDROOT/opt/Sferum/chrome-sandbox

subst 's|%files|%files\n/usr/bin/sferum|' $SPEC
