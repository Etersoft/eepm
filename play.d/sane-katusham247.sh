#!/bin/sh

PKGNAME=katusha-m247-sc
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Linux Scan Driver for katusha m247 Scanner"
URL="https://katusha-it.ru/downloads"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://katusha-it.ru/storage/filemanager/downloads/Katusha%20Devices/m247/Linux%20%D0%B4%D1%80%D0%B0%D0%B8%CC%86%D0%B2%D0%B5%D1%80%20%D1%81%D0%BA%D0%B0%D0%BD%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F%20%D0%9A%D0%B0%D1%82%D1%8E%D1%88%D0%B0%20M247.zip"

install_pack_pkgurl
