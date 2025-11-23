#!/bin/sh

PKGNAME=wps-office-cn
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WPS Office for Linux from the official site (Chinese version)"
URL="https://www.wps.cn/product/wpslinux"

. $(dirname $0)/common.sh

warn_version_is_not_supported

CHN_DEB_URL=$(eget -O- 'https://linux.wps.cn' | grep -Po "(?<=['\"])http.+?_amd64.deb(?=['\"])" | sort -u)

# fix URL: https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=wps-office-cn
uri="$(printf '%s\n' "$CHN_DEB_URL" | sed 's#https://wps-linux-personal.wpscdn.cn##')"
secrityKey='7f8faaaa468174dc1c9cd62e5f218a5b'
timestamp10=$(date '+%s')
md5hash=$(printf '%s%s%s' "$secrityKey" "$uri" "$timestamp10" | md5sum | cut -d' ' -f1)
PKGURL="$CHN_DEB_URL?t=${timestamp10}&k=${md5hash}"

export EPM_REPACK_SCRIPT="$PKGNAME"
install_pkgurl
