#!/bin/sh

# Repack blksnap (Veeam snapshot DKMS source) rpm for ALT.
# 'kernel-devel' is the RHEL build-dependency name; on ALT DKMS builds against
# kernel-headers-modules-<flavour> for the running kernel, which the play script
# assures separately. Drop the RHEL name so the package installs.

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst '/^Requires:[[:space:]]*kernel-devel$/d' $SPEC
