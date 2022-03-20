#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=chromium-gost
PRODUCTCUR=chromium-gost-stable
PRODUCTDIR=/opt/$PRODUCT


. $(dirname $0)/common-chromium-browser.sh

# can be in the repo
subst '1iConflicts:chromium-gost' $SPEC

set_alt_alternatives 62

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

install_deps

# use standalone config dir
subst 's|exec -a "$0" "$HERE/chrome" "$@"||' $BUILDROOT/$PRODUCTDIR/$PRODUCT
cat <<EOF >>$BUILDROOT/$PRODUCTDIR/$PRODUCT
if ! [[ "\$*" =~ \-user\-data\-dir= ]]; then
       exec -a "\$0" "\$HERE/chrome" "-user-data-dir=\$HOME/.config/chromium-gost" "\$@"
else
       exec -a "\$0" "\$HERE/chrome" "\$@"
fi
EOF

