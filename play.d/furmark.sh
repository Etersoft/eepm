#!/bin/sh

PKGNAME=furmark
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="GPU Stress Test OpenGL and Vulkan Graphics Benchmark"
URL="https://www.geeks3d.com/furmark/downloads/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

DL_VER="$(eget -O- "https://www.geeks3d.com/furmark/downloads/" | grep -o '/dl/show/.*linux.*[0-9]\{3\}' | head -n 1 | grep -o "[0-9]\{3\}" | head -n 1 )"

PKGURL="https://www.geeks3d.com/dl/get/$DL_VER"

install_pack_pkgurl
