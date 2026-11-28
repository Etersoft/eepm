#!/bin/sh

PKGNAME=pvs-studio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="PVS-Studio static code analyzer for C and C++ from the official site"
URL="https://pvs-studio.ru/ru/pvs-studio/"
TIPS="PVS-Studio requires a license: run pvs-studio-analyzer credentials NAME KEY (a trial key can be requested on the site)."

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # https://files.pvs-studio.ru/rpm/pvs-studio-8.01.110904.869-x86_64.rpm
    PKGURL="$(eget --list --latest https://files.pvs-studio.ru/rpm/ "pvs-studio-[0-9]*-x86_64.rpm")" || fatal "Can't get package URL"
else
    PKGURL="https://files.pvs-studio.ru/pvs-studio-$VERSION-x86_64.rpm"
fi

install_pkgurl || exit

echo
echo "$TIPS"
