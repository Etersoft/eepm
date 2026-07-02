#!/bin/sh

PKGNAME=geforce-now
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='NVIDIA GeForce NOW cloud gaming from the official NVIDIA Flatpak repository'
URL="https://www.nvidia.com/en-us/geforce-now/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

epm assure ostree || fatal

PKGURL=$(get_flatpak_app_dir "https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo" "com.nvidia.geforcenow" "master" "x86_64")

install_pack_pkgurl
