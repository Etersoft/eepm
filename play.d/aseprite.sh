#!/bin/sh

PKGNAME=aseprite
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION="Animated sprite editor and pixel art tool (built locally via Stapler)"
URL="https://www.aseprite.org"

. $(dirname $0)/common.sh

# Aseprite ships no free prebuilt binary and its EULA forbids redistribution,
# but it allows building the app yourself for personal use. So we do not
# repackage a binary - we set up Stapler (stplr) with the community 'aides'
# recipe repo and let epm build+install aseprite locally from source.
epm prescription stplr || fatal "Can't set up Stapler (stplr)"

epm install stplr:aseprite
