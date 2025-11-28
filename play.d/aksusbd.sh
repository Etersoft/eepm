#!/bin/sh

PKGNAME=aksusbd
SUPPORTEDARCHES="x86_64 x86 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Sentinel LDK daemon (HASP) from the official site"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Site: https://supportportal.gemalto.com/csm?id=kb_category&kb_category=f9ae29a44fb2c304873b69d18110c764

# Sentinel LDK Linux Runtime Installer Script 10.14
PKGURL="ipfs://QmTu5yGU6tqNA7Sh8BMtCsW3pLW3AMAcYcBv6ZwkmpLe8w?filename=Sentinel_LDK_Linux_Run-time_Installer_script.tar.gz"

install_pack_pkgurl || exit

# TODO: move to the package?
serv aksusbd try-restart

serv --quiet aksusbd status >/dev/null && exit

echo
echo "Note: run
# serv aksusbd on
to start Sentinel license service
"
