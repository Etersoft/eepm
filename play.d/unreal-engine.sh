#!/bin/sh

PKGNAME=unreal-engine
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unreal Engine (stub for epm pack)"
URL="https://www.unrealengine.com/"

. $(dirname $0)/common.sh

cat <<EOF
Since Epic Games provides the Unreal Engine download link only to registered users, we cannot create a complete play script.

We ever can't create rpm package for you due 4Gb limit for RPM 4 packages.

Please use epm play unreal-engine-stub.
EOF

#Please download the zip file manually from https://www.unrealengine.com/linux and run
#epm install Linux_Unreal_Engine**.zip
#EOF
