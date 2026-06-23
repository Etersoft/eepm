#!/bin/sh

PKGNAME=XPPenLinux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="XP-Pen (Official) Linux utility"
URL="https://www.xp-pen.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# the .deb installer is shared across all XP-Pen tablets,
# scrape any product page for its current data-id/data-pid pair
ids=$(eget -O- "https://www.xp-pen.com/download/deco-01-v2.html" 2>/dev/null | awk '
    /XPPenLinux[^<]*\.deb/ { found=1 }
    found && /data-ext="deb"/ {
        match($0, /data-id="[0-9]+"/);  id=substr($0,  RSTART+9,  RLENGTH-10)
        match($0, /data-pid="[0-9]+"/); pid=substr($0, RSTART+10, RLENGTH-11)
        print id, pid
        exit
    }')

[ -n "$ids" ] || fatal "Cannot detect XPPen latest .deb URL from the vendor page"

id=${ids% *}
pid=${ids#* }
PKGURL="https://www.xp-pen.com/download/file.html?id=$id&pid=$pid&ext=deb"

install_pkgurl
