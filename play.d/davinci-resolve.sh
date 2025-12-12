#!/bin/sh

PKGNAME=davinci-resolve
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Professional A/V post-production software suite from Blackmagic Design (stub for epm pack)"
URL="https://www.blackmagicdesign.com"

. $(dirname $0)/common.sh

cat <<EOF
Since Blackmagic provides the DaVinci Resolve download link only to registered users, we cannot create a complete play script. Therefore, to repackage DaVinci Resolve, run:

epm install D****.run
EOF
