#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# deb has hardlinks from /usr/share/icons/hicolor/ to /opt/YTDownloader/
# which fail with cpio: link during rpm install, replace with copies
for i in $BUILDROOT/usr/share/icons/hicolor/*/apps/ytdownloader.png ; do
    [ -f "$i" ] || continue
    tmp="$i.tmp"
    cp "$i" "$tmp"
    mv "$tmp" "$i"
done

add_electron_deps
