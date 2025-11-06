#!/bin/sh

PKGNAME=unreal-engine
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION=" (stub for epm pack)"
URL="https://www.unrealengine.com/"

. $(dirname $0)/common.sh

DESCRIPTION="Professional A/V post-production software suite from Blackmagic Design (stub for epm pack)"
URL="https://www.blackmagicdesign.com"

cat <<EOF
Since Epic Games provides the Unreal Engine download link only to registered users, we cannot create a complete play script.

Please download the zip file manually from https://www.unrealengine.com/linux and run
epm install Linux_Unreal_Engine**.zip
EOF

