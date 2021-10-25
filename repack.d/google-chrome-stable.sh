#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=google-chrome

subst 's|%files|%files\n/usr/share/icons/hicolor/*x*/apps/*.png|' $SPEC

# Make relative symlink
rm -f $BUILDROOT/usr/bin/google-chrome-stable
ln -s ../../opt/google/chrome/google-chrome $BUILDROOT/usr/bin/google-chrome-stable
ln -s google-chrome-stable $BUILDROOT/usr/bin/google-chrome

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
