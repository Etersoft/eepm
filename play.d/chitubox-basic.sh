#!/bin/sh

PKGNAME=chitubox-basic
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="All-in-one SLA/DLP/LCD slicer for 3D printing"
URL="https://www.chitubox.com/"

. $(dirname $0)/common.sh

# See https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=chitubox-free-bin
VERSION=2.3.1

PKGURL="https://sac.chitubox.com/software/download.do?installerUrl=https%3A%2F%2Fdownload.chitubox.com%2F17839%2Fv${VERSION}%2FCHITUBOX_Basic_linux_Installer_${VERSION}&softwareId=17839&softwareVersionId=v${VERSION}"

install_pack_pkgurl
