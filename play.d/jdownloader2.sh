#!/bin/sh

PKGNAME=jdownloader2
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Download management tool that makes downloading as easy and fast as it should be"
URL="https://jdownloader.org/jdownloader2"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PAGE="$(eget -O- "$URL")" || fatal "Can't load $URL."
VERSION="$(echo "$PAGE" | sed -n 's|.*<meta name="date" content="\([0-9][0-9][0-9][0-9]\)-\([0-9][0-9]\)-\([0-9][0-9]\).*|\1\2\3|p' | head -n1)"
MEGAURL="$(echo "$PAGE" | sed -n 's|.*href="\([^"]*mega.nz/file/[^"]*\)".*Download (MULTIOS JAR.*|\1|p' | head -n1)"
[ -n "$MEGAURL" ] || fatal "Can't find JDownloader MEGA URL."
[ -n "$VERSION" ] || fatal "Can't find JDownloader version date."

epm assure megatools || fatal

cd_to_temp_dir
megadl "$MEGAURL" || fatal "Can't download JDownloader from MEGA."
[ -s JDownloader.jar ] || fatal "Can't find downloaded JDownloader.jar."
PKGURL="$(pwd)/JDownloader.jar"

install_pack_pkgurl "$VERSION"
