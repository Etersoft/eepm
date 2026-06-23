#!/bin/sh

PKGNAME=dmde-con
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="Powerful tool for data searching, editing, and recovery on disks (Console version)"
URL="https://dmde.com/download.html"

. $(dirname $0)/common.sh

case "$(epm print info -a)" in
    x86_64)
        arch=lin64
        archname="64-bit"
        ;;
    x86)
        arch=lin32
        archname="32-bit"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest "$URL" "dmde-*-$arch-con.zip")"
    [ -n "$PKGURL" ] || fatal "Can't find DMDE Linux $archname console download URL."
else
    PKGURL="https://dmde.com/download/dmde-$(echo "$VERSION" | tr . -)-$arch-con.zip"
fi

install_pack_pkgurl

cat <<EOF

Note: DMDE uses sudo to run with elevated privileges. Sudo must be enabled in the system:
$ su -
# control sudowheel enabled
# exit
EOF
