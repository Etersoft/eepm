#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command

cd .$PRODUCTDIR || fatal

for i in data-dir gnome-platform lib meta scripts usr ; do
    remove_dir $PRODUCTDIR/$i
done

for i in *.sh ; do
    remove_file $PRODUCTDIR/$i
done

cd >/dev/null

add_libs_requires
