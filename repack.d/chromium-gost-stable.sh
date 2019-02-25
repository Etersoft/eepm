#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

subst 's|%dir "/opt/chromium-gost"|%dir "/opt/chromium-gost"\n/usr/share/icons/hicolor/*x*/apps/*.png|' $SPEC

# Make relative symlink
rm -f $BUILDROOT/usr/bin/chromium-gost-stable
ln -s ../../opt/chromium-gost/chromium-gost $BUILDROOT/usr/bin/chromium-gost-stable
ln -s chromium-gost-stable $BUILDROOT/usr/bin/chromium-gost

for i in 16 22 24 32 48 64 128 256 ; do
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    cp $BUILDROOT/opt/chromium-gost/product_logo_$i.png $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/chromium-gost.png
done

rm -f $BUILDROOT/etc/cron.daily/chromium-gost
subst 's|.*/etc/cron.daily/chromium-gost.*||' $SPEC

subst 's|exec -a "$0" "$HERE/chrome" "$@"||' $BUILDROOT/opt/chromium-gost/chromium-gost
cat <<EOF >>$BUILDROOT/opt/chromium-gost/chromium-gost
if ! [[ "\$*" =~ \-user\-data\-dir= ]]; then
       exec -a "\$0" "\$HERE/chrome" "-user-data-dir=\$HOME/.config/chromium-gost" "\$@"
else
       exec -a "\$0" "\$HERE/chrome" "\$@"
fi
EOF
