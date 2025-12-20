#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/google/earth/pro

. $(dirname $0)/common.sh

remove_dir /etc/cron.daily

# Avoid objdump: /var/tmp/tmp.5cjDQD1wzG/google-earth-pro-stable-current.x86_64.rpm.tmpdir/google-earth-pro-stable-7.3.6.10201/opt/google/earth/pro/libdebuginfod.so.1: формат файла не распознан
remove_file /opt/google/earth/pro/libdebuginfod.so.1

move_file /opt/google/earth/pro/google-earth-pro.desktop /usr/share/applications/google-earth-pro.desktop

move_file /opt/google/earth/pro/product_logo_256.png /usr/share/pixmaps/google-earth-pro.png

