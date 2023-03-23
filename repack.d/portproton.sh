#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=portproton
PRODUCTDIR=/opt/PortProton

. $(dirname $0)/common.sh

add_requires bubblewrap cabextract curl gamemode icoutils libvulkan1 vulkan-tools wget zenity zstd libd3d libMesaOpenCL

filter_from_requires xneur
