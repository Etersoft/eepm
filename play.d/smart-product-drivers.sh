#!/bin/sh

PKGNAME=smart-product-drivers
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SMART Product Drivers for SMART Board interactive whiteboards"
URL="https://support.smarttech.com/docs/software/notebook/notebook-11/en/notebook-11-downloads/11-1sp3.cshtml"

. $(dirname $0)/common.sh

# the vendor publishes only the latest archive
warn_version_is_not_supported

# apt repository archive for Ubuntu 20.04: smart-product-drivers, smart-common, smart-languagesetup, fwupdatesmart and SMART Notebook
PKGURL="https://downloads.smarttech.com/software/linux/nb-for-ubuntu-20/SMART_software_deb_archive.tar.gz"

install_pack_pkgurl
