#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/pentablet
PRODUCTCUR=PenTablet

. $(dirname $0)/common.sh

move_to_opt /usr/lib/pentablet

mkdir -p $BUILDROOT/usr/lib/pentablet/conf/xppen/

#hardcoded in binary file
for i in config.xml dialogpos.ini language.ini name_config.ini; do
    ln -s /opt/pentablet/conf/xppen/$i usr/lib/pentablet/conf/xppen/$i
    pack_file /usr/lib/pentablet/conf/xppen/$i
done


add_bin_exec_command $PRODUCTCUR $PRODUCTDIR/$PRODUCTCUR.sh

fix_desktop_file /usr/lib/pentablet/PenTablet.sh $PRODUCTCUR

