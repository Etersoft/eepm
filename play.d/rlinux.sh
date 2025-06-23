#!/bin/sh

PKGNAME=rlinux
SUPPORTEDARCHES="x86_64"
DESCRIPTION='File recovery utility for the ext2/ext3/ext4 file system'
URL="https://www.r-tt.com/data_recovery_linux/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://www.r-studio.com/downloads/RLinux6_x64.deb"

install_pkgurl
