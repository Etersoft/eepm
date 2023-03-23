#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=portproton
PRODUCTDIR=/opt/PortProton

. $(dirname $0)/common.sh

subst '1iRequires:bubblewrap cabextract curl gamemode icoutils libvulkan1 vulkan-tools wget zenity zstd libd3d libMesaOpenCL' $SPEC

filter_from_requires xneur
