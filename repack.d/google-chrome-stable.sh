#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=google-chrome
PRODUCTDIR=/opt/google/chrome

subst '1iProvides:webclient' $SPEC

subst "s|%files|%files\n/etc/alternatives/packages.d/$PRODUCT|" $SPEC
mkdir -p $BUILDROOT/etc/alternatives/packages.d/
cat <<EOF >$BUILDROOT/etc/alternatives/packages.d/$PRODUCT
/usr/bin/xbrowser	/usr/bin/$PRODUCT	65
/usr/bin/x-www-browser	/usr/bin/$PRODUCT	65
EOF


subst 's|%files|%files\n/usr/share/icons/hicolor/*x*/apps/*.png|' $SPEC

# Make relative symlink
rm -f $BUILDROOT/usr/bin/google-chrome-stable
ln -s ../../opt/google/chrome/google-chrome $BUILDROOT/usr/bin/google-chrome-stable

# short command for run
ln -s google-chrome-stable $BUILDROOT/usr/bin/$PRODUCT
subst 's|%files|%files\n/usr/bin/$PRODUCT|' $SPEC

for i in 16 24 32 48 64 128 256 ; do
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    cp $BUILDROOT/opt/google/chrome/product_logo_$i.png $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/google-chrome.png
done

rm -f $BUILDROOT/etc/cron.daily/google-chrome
subst 's|.*/etc/cron.daily/google-chrome.*||' $SPEC

# unsupported format
rm -f $BUILDROOT/usr/share/menu/$PRODUCT.menu
subst "s|.*/usr/share/menu/$PRODUCT.menu.*||" $SPEC

# google-chrome by default?
#subst 's|exec -a "$0" "$HERE/chrome" "$@"||' $BUILDROOT/opt/google/chrome/google-chrome
#cat <<EOF >>$BUILDROOT/opt/google/chrome/google-chrome
#if ! [[ "\$*" =~ \-user\-data\-dir= ]]; then
#       exec -a "\$0" "\$HERE/chrome" "-user-data-dir=\$HOME/.config/google-chrome" "\$@"
#else
#       exec -a "\$0" "\$HERE/chrome" "\$@"
#fi
#EOF
