#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# see pack.d/smart-product-drivers.sh
SMARTDIR="/opt/smart-technologies"

# Ubuntu renamed libpcre16.so.0 (pcre 8.x) to libpcre16.so.3
a='' patchelf --replace-needed libpcre16.so.3 libpcre16.so.0 "$BUILDROOT$SMARTDIR/common/lib/libQt5Core.so.5" || fatal

# ICU 66 and boost 1.67 from Ubuntu (see pack.d) find each other in common/lib
# (RUNPATH of the executables does not apply to indirect dependencies)
for i in "$BUILDROOT$SMARTDIR/common/lib"/libicu*.so.66* "$BUILDROOT$SMARTDIR/common/lib"/libboost_*.so.1.67.0 ; do
    [ -L "$i" ] && continue
    a='' patchelf --set-rpath '$ORIGIN' "$i" || fatal
done

# Qt SQL plugin for MySQL (libmysqlclient.so.21), not used by the drivers
remove_file "/opt/smart-technologies/common/plugins/sqldrivers/libqsqlmysql.so"

# the tools write their settings there
for i in "/etc/xdg/SMART Technologies Drivers.conf" "/etc/xdg/SMART Technologies/SMART Notebook.conf" ; do
    subst "s|^\"$i\"$|%attr(0666,root,root) %config(noreplace) \"$i\"|" $SPEC
done
mark_config_noreplace "/etc/xdg/SMART Technologies.conf"
mark_config_noreplace "/etc/xdg/SMART Technologies/Language Setup.conf"
