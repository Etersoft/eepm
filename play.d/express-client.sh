#!/bin/sh

PKGNAME=express
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="eXpress client from the official site"
URL="https://express.ms/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://express.ms/download/deb"

epm install $PKGURL
