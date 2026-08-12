#!/bin/sh

PKGNAME=weasis
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Weasis DICOM medical viewer"
URL="https://github.com/nroduit/Weasis"

. $(dirname $0)/common.sh

# Do not use upstream rpm: alien fails to unpack it while repacking.
arch="$(epm print info --debian-arch)"
file="weasis_${VERSION}-${RELEASE}_$arch.deb"

PKGURL=$(eget --list --latest https://github.com/nroduit/Weasis/releases "$file")

# Upstream deb postinstall calls xdg-desktop-menu and fails in headless installs.
install_pkgurl --repack
