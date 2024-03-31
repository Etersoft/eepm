#!/bin/sh

PKGNAME=aksusbd
SUPPORTEDARCHES="x86_64 x86 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Sentinel LDK daemon (HASP) from the official site"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Site: https://supportportal.gemalto.com/csm?id=kb_category&kb_category=f9ae29a44fb2c304873b69d18110c764

# 8.53 version
#PKGURL="https://supportportalsirius.thalesgroup.com/Files%2F01954629db5ea78cfe0aff3dbf9619a0%2FSentinel_LDK_Linux_Run-time_Installer_script.tar.gz?Expires=1681977609125&KeyName=sirius-prod-signing-key&Signature=KGaEmanTGXEeN7Aop4dg5EqOgKY"

# Sentinel LDK Linux Runtime Installer Script 9.15
#PKGURL="https://supportportalsirius.thalesgroup.com/Files%2F01954629db5ea78cfe0aff3dbf9619a0%2FSentinel_LDK_Linux_Run-time_Installer_script.tar.gz?Expires=1711995112418&KeyName=sirius-prod-signing-key&Signature=z4B1KnPQtvp2oCSw2ulMGDLcwws"
PKGURL="ipfs://QmXkf4Wz9wSSqpGbLyebwYVtZ5PTYcNM12g4FtzXjDQiX4?filename=Sentinel_LDK_Linux_Run-time_Installer_script.tar.gz"

install_pack_pkgurl
