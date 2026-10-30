#!/bin/sh

BASEPKGNAME=dmde-con
PRODUCTALT="'' beta"
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="Powerful tool for data searching, editing, and recovery on disks (Console version)"
URL="https://dmde.com/download.html"
TIPS="Run 'epm play dmde-con=beta' to install beta version."

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

if [ "$BRANCH" = "beta" ] ; then
    beta=-beta
    beta_filter=
    override_pkgname "$BASEPKGNAME"
else
    beta=
    beta_filter=-v
fi

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list "$URL" "dmde-*-$arch-con.zip" | grep $beta_filter -- '-beta-' | sort -V | tail -n1)"
    [ -n "$PKGURL" ] || fatal "Can't find DMDE Linux $archname console download URL."
else
    PKGURL="https://dmde.com/download/dmde-$(echo "$VERSION" | tr . -)$beta-$arch-con.zip"
fi

install_pack_pkgurl

cat <<EOF

Note: DMDE uses sudo to run with elevated privileges. Sudo must be enabled in the system:
$ su -
# control sudowheel enabled
# exit
EOF
