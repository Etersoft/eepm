#!/bin/sh

PKGNAME=hplip-plugin
SUPPORTEDARCHES="x86_64 x86 armhf aarch64"
VERSION="$2"
DESCRIPTION='Binary plugin for HPs hplip printer driver library'
URL="https://developers.hp.com/hp-linux-imaging-and-printing/binary_plugin.html"

# The plugin must match the installed HPLIP, including during update checks.
get_target_version()
{
    epm status --installed hplip 2>/dev/null || return 1
    epm print version for package hplip 2>/dev/null | head -n1
}

. $(dirname $0)/common.sh

VERSION="$(get_target_version)" || fatal "hplip package is not installed"
[ -n "$VERSION" ] || fatal "Can't determine the installed hplip version"

export EGET_OPTIONS="--user-agent"

if [ "$(epm print compare "$VERSION" 3.25.2)" != "-1" ] ; then
    PKGURL="$(eget --list https://developers.hp.com/hp-linux-imaging-and-printing/plugins "hplip-$VERSION-plugin.run")"
else
    PKGURL="https://developers.hp.com/sites/default/files/hplip-$VERSION-plugin.run"
fi

# fallback to openprinting.org mirror if HP site is not accessible
if [ -z "$PKGURL" ] || ! eget --check-url "$PKGURL" ; then
    PKGURL="https://www.openprinting.org/download/printdriver/auxfiles/HP/plugins/hplip-$VERSION-plugin.run"
fi

install_pack_pkgurl
