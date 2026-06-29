#!/bin/sh

PKGNAME="far2l-portable"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="FAR2L Portable from the official site"
URL="https://github.com/spvkgn/far2l-portable/releases"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# The portable AppImage is built against a newer glibc (needs GLIBC_2.34); on older
# systems (e.g. p10) it fails at startup. far2l is packaged natively in the repo, so
# point there instead of installing something that won't run.
is_glibc_enough 2.34 || fatal "far2l-portable needs glibc >= 2.34 and will not run here. Install the native package instead: epm install far2l"

PKGURL=$(eget --list --latest https://github.com/spvkgn/far2l-portable/releases "far2l*x86_64*.AppImage.tar")

install_pack_pkgurl
