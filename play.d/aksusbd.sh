#!/bin/sh

PKGNAME=aksusbd
SUPPORTEDARCHES="x86_64 x86 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Sentinel LDK daemon (HASP) from the official site"

. $(dirname $0)/common.sh

# Site: https://supportportal.gemalto.com/csm?id=kb_category&kb_category=f9ae29a44fb2c304873b69d18110c764

case "$VERSION" in
    ""|"*"|10.32)
           # Sentinel LDK Linux Runtime Installer Script 10.32 (latest, default)
           PKGURL="ipfs://QmQshW8RR9ZHnswqyWBreknhFr5YHUioifwW9ZUDMMQz55?filename=Sentinel_LDK_Linux_Run-time_Installer_script.tar.gz"
           checksum="md5hash:bd1371bfb73872849d1edb386c4f2f86"
           ;;
    10.21)
           # Sentinel LDK Linux Runtime Installer Script 10.21
           PKGURL="ipfs://QmYE9yzRGnTMRh5NBsrSG3sxgCAVE4EMYnpJ9vAhhprQcq?filename=Sentinel_LDK_Linux_Run-time_Installer_script.tar.gz"
           checksum="md5hash:3855b9b2e3ca3077f5e1efec6b2ccb84"
           ;;
    10.14)
           # Sentinel LDK Linux Runtime Installer Script 10.14
           PKGURL="ipfs://QmTu5yGU6tqNA7Sh8BMtCsW3pLW3AMAcYcBv6ZwkmpLe8w?filename=Sentinel_LDK_Linux_Run-time_Installer_script.tar.gz"
           checksum="md5hash:f1c7c7f3a6d6647713b7df84abbb6a09"
           ;;
    *)
           fatal "Unsupported version aksusbd $VERSION"
           ;;
esac

install_pack_pkgurl "" $checksum || exit

# TODO: move to the package?
serv aksusbd try-restart

serv --quiet aksusbd status >/dev/null && exit

echo
echo "Note: run
# serv aksusbd on
to start Sentinel license service
"
