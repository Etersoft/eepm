#!/bin/sh

PKGNAME=express
SUPPORTEDARCHES="x86_64"
#VERSION="$2"
DESCRIPTION="eXpress client from the official site"
URL="https://express.ms/"

. $(dirname $0)/common.sh

PKG="https://express.ms/download/deb"

epm install $PKG
