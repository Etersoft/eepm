#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=pulsar
PRODUCTDIR=/opt/Pulsar

. $(dirname $0)/common-chromium-browser.sh

add_electron_deps

add_unirequires coreutils findutils grep sed /usr/bin/git /usr/bin/node /usr/bin/npm /usr/bin/npx util-linux which xprop python3

install_file $PRODUCTDIR/resources/pulsar.sh /usr/bin/$PRODUCT
chmod a+x $BUILDROOT/usr/bin/$PRODUCT
add_bin_link_command ppm $PRODUCTDIR/resources/app/ppm/bin/apm

# replace embedded xdg-open
for EMBDIR in $PRODUCTDIR/resources/app/ppm/node_modules/open/xdg-open ; do
    echo "Removing $BUILDROOT$EMBDIR ..."
    rm $BUILDROOT$EMBDIR
    ln -s /usr/bin/$(basename $EMBDIR) $BUILDROOT$EMBDIR
done

