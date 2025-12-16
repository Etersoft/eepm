#!/bin/sh

PKGNAME=servo
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='A prototype web browser engine written in the Rust language'
URL="https://servo.org"

. $(dirname $0)/common.sh

if ! is_glibc_enough 2.34 ; then
    fatal "glibc is too old, needed glibc 2.34 or above"
fi

warn_version_is_not_supported

# https://github.com/servo/servo/releases/download/v0.0.2/servo-x86_64-linux-gnu.tar.gz
PKGURL=$(get_github_url "https://github.com/servo/servo" "servo-x86_64-linux-gnu.tar.gz")

VERSION=$(basename $(dirname $PKGURL) | sed -e 's|^v||')

install_pack_pkgurl $VERSION
