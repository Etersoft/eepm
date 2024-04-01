#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=synology-drive
PRODUCTDIR=/opt/Synology/SynologyDrive

. $(dirname $0)/common.sh

cd $BUILDROOT/$PRODUCTDIR || exit

# disable autoupdate
remove_file $PRODUCTDIR/package/cloudstation/bin/cloud-drive-auto-updater

# Suggests
# epm install --skip-installed libnautilus libnautilus-extension-compat
filter_from_requires libnautilus

# /usr/lib/nautilus/extensions-3.0/libnautilus-drive-extension.so: library libnautilus-extension.so.1 not found
# but we have
# libnautilus /usr/lib64/libnautilus-extension.so.4

remove_file /usr/lib/nautilus/extensions-4/libnautilus-drive-extension-4.so
remove_file /usr/lib/nautilus/extensions-3.0/libnautilus-drive-extension.so

# fix ALT p10 install (TODO: restore for Sisyphus)
#   synology-drive: Depends: libc.so.6(GLIBC_2.33)(64bit) but it is not installable
#                  Depends: libc.so.6(GLIBC_2.34)(64bit) but it is not installable
#                  Depends: libstdc++.so.6(GLIBCXX_3.4.29)(64bit) but it is not installable
remove_file $PRODUCTDIR/package/cloudstation/icon-overlay/14/lib/plugin-cb-4.so || :
# skip nautilus support
remove_file $PRODUCTDIR/package/cloudstation/icon-overlay/14/lib/plugin-cb.so || :
remove_file $PRODUCTDIR/package/cloudstation/icon-overlay/15/lib/plugin-cb.so || :
# TODO: parse
# https://www.synology.com/api/support/findDownloadInfo?lang=ru-ru&product=DS2411%2B&major=6&minor=2

add_libs_requires
