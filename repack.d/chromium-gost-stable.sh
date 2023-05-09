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
# TODO: report to the upsteam
# remove incorrect icons (https://bugzilla.altlinux.org/43760)
remove_file /usr/share/icons/hicolor/32x32/apps/chromium-gost.png
remove_file /usr/share/icons/hicolor/16x16/apps/chromium-gost.png

cleanup

add_bin_commands

use_system_xdg

install_deps

fix_desktop_file /usr/bin/$PRODUCTCUR

# TODO: report to the upstream
subst 's|Name=Chromium-Gost|Name=Chromium-Gost Web Browser\nName[ru]=Веб-браузер Chromium-gost|' $BUILDROOT/usr/share/applications/*.desktop
subst 's|GenericName=Web Browser|GenericName=Chromium-Gost Web Browser|' $BUILDROOT/usr/share/applications/*.desktop
subst 's|GenericName\[ru\]=Веб-браузер|GenericName[ru]=Веб-браузер Chromium-gost|' $BUILDROOT/usr/share/applications/*.desktop

# use standalone config dir
subst 's|exec -a "$0" "$HERE/chrome" "$@"||' $BUILDROOT/$PRODUCTDIR/$PRODUCT
cat <<EOF >>$BUILDROOT/$PRODUCTDIR/$PRODUCT
#!/bin/sh
if ! [[ "\$*" =~ \-user\-data\-dir= ]]; then
       exec -a "\$0" "\$HERE/chrome" "-user-data-dir=\$HOME/.config/chromium-gost" "\$@"
else
       exec -a "\$0" "\$HERE/chrome" "\$@"
fi
EOF

