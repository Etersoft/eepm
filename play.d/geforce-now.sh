#!/bin/sh

PKGNAME=geforce-now
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='NVIDIA GeForce NOW cloud gaming from the official NVIDIA Flatpak repository'
URL="https://www.nvidia.com/en-us/geforce-now/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# ostree is used by pack.d to checkout the app from NVIDIA's flatpak repository
epm assure ostree || fatal

# The app is published in a flatpak *repository* (not a single bundle), so there
# is no archive to download here: pack.d parses this .flatpakrepo file and pulls
# the app via ostree. epm play only fetches the repo descriptor.
PKGURL="https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo"

install_pack_pkgurl
