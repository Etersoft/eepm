#!/bin/sh

PKGNAME=weasis
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Weasis DICOM medical viewer"
URL="https://github.com/nroduit/Weasis"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"
file="weasis_$VERSION-1_$arch.deb"

PKGURL=$(eget --list --latest https://github.com/nroduit/Weasis/releases $file) || fatal "Can't get package URL"

epm install "$PKGURL"
