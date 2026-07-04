#!/bin/sh

PKGNAME=assistant
SKIPREPACK=1
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Assistant (Ассистент) from the official site"
URL="https://мойассистент.рф"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info -a)"
pkg="$(epm print info -p)"

# Vendor site is a SPA; downloads are served by /WebApi/Platforms/Download/<id>,
# where <id> is a numeric build id that changes on every release (6.5 -> 7.0
# bumped the x86_64 rpm/deb ids from 1376/1375 to 1515/1514). Resolve it
# dynamically from the Linux catalog instead of pinning ids per release.
# Platform 2 = Linux. The catalog lists every build (x86_64 + aarch64, GUI +
# console); tell them apart by ASCII fragments in the title: "RPM"/"DEB", the
# presence of "ARM" (aarch64) and of "(" (the console "cassistant" variant).
CATALOG="https://xn--80akicokc0aablc.xn--p1ai/api/platform-item/2"
DLBASE="https://lk2.xn--80akicokc0aablc.xn--p1ai/WebApi/Platforms/Download"

case "$pkg" in
    rpm) mark=RPM ;;
    deb) mark=DEB ;;
    *) fatal "$(epm print info -e) is not supported (package type is $pkg)" ;;
esac

case "$arch" in
    x86_64) arm="" ;;
    aarch64) arm="arm" ;;
    *) fatal "$(epm print info -e) is not supported (arch $arch)" ;;
esac

# Id is the leaf right before Title in the parsed catalog, so pick the GUI build
# of the requested arch/format and read its sibling Id.
ITEMID="$(fetch_url "$CATALOG" | epm --inscript --quiet tool json -b | \
    awk -F'\t' -v mark="$mark" -v arm="$arm" '
        $1 ~ /,"Id"\]$/ { id=$2 }
        $1 ~ /,"Title"\]$/ {
            t=$2
            if (index(t, mark) > 0 \
                && (arm == "arm" ? index(t, "ARM") > 0 : index(t, "ARM") == 0) \
                && index(t, "(") == 0) { print id; exit }
        }')" || fatal "Can't read assistant catalog from $CATALOG"

[ -n "$ITEMID" ] || fatal "Can't resolve assistant build for $arch/$pkg in $CATALOG"

PKGURL="$DLBASE/$ITEMID"

# after repack on ALT:
#  assistant: Требует: /lib/init/vars.sh но пакет не может быть установлен
#             Требует: libyuv.so()(64bit) но пакет не может быть установлен

[ "$(epm print info -s)" = "alt" ] && epmi --skip-installed fontconfig-disable-type1-font-for-assistant

LANG=ru_RU.UTF8 install_pkgurl || exit

echo "Note:
Vendor suggest run /opt/assistant/scripts/setup.sh --install after install.
Vendor suggest run /opt/assistant/scripts/setup.sh --uninstall before removing the package.
Warning! This script will setup daemon. It is dangerous. Use this script and this package at your own risk.
"
