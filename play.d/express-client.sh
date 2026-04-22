#!/bin/sh

PKGNAME=express
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="eXpress client from the official site"
URL="https://express.ms/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://express.ms/download/deb"

# follow redirect to get the real filename (eget would save as "deb" otherwise)
realurl="$(eget --get-real-url "$PKGURL" 2>/dev/null)"
[ -n "$realurl" ] && PKGURL="$realurl"

install_pkgurl
