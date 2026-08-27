#!/bin/sh

PKGNAME=xod-client-electron
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A visual programming language for microcontrollers"
URL="https://xod.io/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        # https://storage.googleapis.com/releases.xod.io/v0.38.0/xod-client-electron-0.38.0.x86_64.rpm?X-Amz-Algorithm=AWS4-HMAC-SHA256&amp;...
        mask="xod-client-electron*.x86_64.rpm*"
        ;;
    *)
        # https://storage.googleapis.com/releases.xod.io/v0.38.0/xod-client-electron_0.38.0_amd64.deb?X-Amz-Algorithm=AWS4-HMAC-SHA256&amp;...
        mask="xod-client-electron_*_amd64.deb*"
        ;;
esac

PKGURL=$(eget --list --latest "$URL" "$mask")
# Signed query parameters from xod.io are HTML-escaped and expire; the object itself is public.
PKGURL="${PKGURL%%\?*}"

install_pkgurl
