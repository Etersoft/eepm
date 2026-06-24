#!/bin/sh

PKGNAME=realvnc-vnc-viewer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Real VNC Viewer from the official site"
URL="https://www.realvnc.com/en/connect/download/viewer/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"


case $pkgtype in
    rpm)
        mask='RealVNC-Connect-Viewer-[0-9.]*-Linux-x64\.rpm' ;;
    *)
        mask='RealVNC-Connect-Viewer-[0-9.]*-Linux-x64\.deb' ;;
esac

# RealVNC no longer keeps classic Linux viewer packages under viewer.files and
# now publishes current Linux builds on the download page as
# RealVNC-Connect-Viewer-* files. Old pinned versions are not reliable there,
# so always resolve the latest vendor-published x64 package from the page.
 
PKGFILE="$(fetch_url "$URL" | grep -Eo "$mask" | sort -Vu | tail -n1)"

[ -n "$PKGFILE" ] || fatal "Can't get package file name from $URL."

PKGURL="https://downloads.realvnc.com/download/file/realvnc-connect-viewer/$PKGFILE"

install_pkgurl
