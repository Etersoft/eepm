#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# source file: 1c83-client-8.3.22.1851.tar

PRODUCT=1c83-client.sh
PRODUCTDIR=/opt/1cv8

. $(dirname $0)/common.sh

# installing from tar, so we need fill some fields here
subst "s|^Group:.*|Group: Office|" $SPEC
subst "s|^License: unknown$|License: Proprietary|" $SPEC
subst "s|^URL:.*|URL: https://1c.ru|" $SPEC
subst "s|^Summary:.*|Summary: 1C 8.3 Client|" $SPEC

subst '1iAutoProv:no' $SPEC

#remove_file /usr/local/bin/$PRODUCT
#add_bin_link_command

if [ -d "$BUILDROOT/opt/1cv8/x86_64" ] ; then
    arch="x86_64"
elif [ -d "$BUILDROOT/opt/1cv8/i586" ] ; then
    arch="i586"
else
    fatal "Unsupported arch"
fi

VERSION="$(basename $(echo $BUILDROOT/opt/1cv8/$arch/8.3.*))"

remove_dir /opt/1cv8/$arch/$VERSION/ExtDst

epm assure patchelf || exit

for i in $BUILDROOT$PRODUCTDIR/*/*/lib* ; do
    a= patchelf --set-rpath "\$ORIGIN:$PRODUCTDIR/common" $i
done

for i in $BUILDROOT$PRODUCTDIR/common/lib* ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done

#epm install --skip-installed libmfx || epm install 316139 || fatal "Can't install libmfx"

