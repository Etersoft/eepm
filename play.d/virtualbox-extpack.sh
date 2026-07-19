#!/bin/sh

PKGNAME=virtualbox-extpack
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Oracle VM VirtualBox Extension pack from the official site (personal use only)'
URL="https://www.virtualbox.org/wiki/Downloads"

# The extension pack must match the installed VirtualBox, so the version we
# install is the installed VirtualBox version. check_for_product_update (called
# below during common.sh sourcing) calls get_target_version to learn the version
# to compare the installed extpack against — instead of app-versions, which would
# re-install the same matching version on every --update when the installed
# VirtualBox lags behind the latest release.
get_target_version()
{
    epm status --installed virtualbox 2>/dev/null || return 1
    epm print version for package virtualbox 2>/dev/null | head -n1
}

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # use latest virtualbox version
    VERSION=$(basename $(eget --list --latest https://download.virtualbox.org/virtualbox/ "^[0-9]*"))
else
    # always install the version corresponding to the installed virtualbox
    epm status --installed virtualbox || fatal "virtualbox package is not installed"
    VERSION="$(get_target_version)"
fi

if [ "$(epm print compare "$VERSION" 7.1.0)" != "-1" ] ; then
    pkgname="Oracle_VirtualBox_Extension_Pack"
else
    pkgname="Oracle_VM_VirtualBox_Extension_Pack"
fi


PKGURL="https://download.virtualbox.org/virtualbox/$VERSION/$pkgname-$VERSION.vbox-extpack"

install_pack_pkgurl
