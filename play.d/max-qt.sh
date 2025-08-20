#!/bin/sh

PKGNAME=max-qt
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Быстрое и лёгкое приложение для общения и решения повседневных задач (перепаковка Qt версии через wine)'
URL="https://max.ru/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Latest version worked on wine
VERSION="25_06_00"
PKGURL="ipfs://QmRpuMCbe6dJvGPCqDPUwF3xkXSdtEoSyq6JGy5DsZsSL1"

install_pack_pkgurl $VERSION
