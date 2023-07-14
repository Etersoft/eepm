#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=portmaster
PRODUCTDIR=/opt/safing/portmaster

. $(dirname $0)/common-chromium-browser.sh

install -D -m644 .$PRODUCTDIR/portmaster.service ./lib/systemd/system/portmaster.service
remove_file $PRODUCTDIR/portmaster.service
install -D -m644 .$PRODUCTDIR/portmaster.desktop ./usr/share/applications/portmaster.desktop
remove_file $PRODUCTDIR/portmaster.desktop
install -D -m644 .$PRODUCTDIR/portmaster_notifier.desktop ./usr/share/applications/portmaster_notifier.desktop
remove_file $PRODUCTDIR/portmaster_notifier.desktop

mkdir -p $BUILDROOT/usr/bin/
cat <<EOF >$BUILDROOT/usr/bin/$PRODUCT
#!/bin/sh
$PRODUCTDIR/portmaster-start app --data=$PRODUCTDIR "\$@"
EOF
chmod a+x $BUILDROOT/usr/bin/$PRODUCT
pack_file /usr/bin/$PRODUCT

echo "Dowloading ... "
.$PRODUCTDIR/portmaster-start --data $BUILDROOT$PRODUCTDIR update || fatal

p="$(basename $(dirname $PRODUCTDIR/updates/linux_amd64/app/portmaster-app_v*/chrome-sandbox))"
fix_chrome_sandbox $PRODUCTDIR/updates/linux_amd64/app/$p/chrome-sandbox

pack_file $PRODUCTDIR/updates

install_deps

set_autoreq 'yes'
