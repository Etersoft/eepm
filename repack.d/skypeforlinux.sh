#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=skype
PRODUCTCUR=skypeforlinux
PRODUCTDIR=/opt/skype

. $(dirname $0)/common-chromium-browser.sh

# remove key install script
remove_dir /opt/skypeforlinux

move_to_opt /usr/share/skypeforlinux

subst "s|^SKYPE_PATH=.*|SKYPE_PATH=$PRODUCTDIR/skypeforlinux|" $BUILDROOT/usr/bin/skypeforlinux

subst '1iAutoProv:no' $SPEC

# ignore embedded libs
drop_embedded_reqs

# usual command skype
mkdir -p $BUILDROOT/usr/bin/
ln -s /usr/bin/skypeforlinux $BUILDROOT/usr/bin/skype
subst 's|%files|%files\n/usr/bin/skype|' $SPEC

fix_chrome_sandbox

fix_desktop_file /usr/bin/skypeforlinux
