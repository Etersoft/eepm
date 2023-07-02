#!/bin/sh

PKGNAME=weasis
SUPPORTEDARCHES="x86_64 aarch64 armhf"
DESCRIPTION="Weasis DICOM medical viewer"
VERSION="$2"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"
file="weasis_$VERSION-1_$arch.deb"

PKGURL=$(epm tool eget --list --latest https://github.com/nroduit/Weasis/releases $file) || fatal "Can't get package URL"

epm install "$PKGURL"

