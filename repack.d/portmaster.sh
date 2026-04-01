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

DATADIR=/var/lib/portmaster

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
exec $PRODUCTDIR/portmaster-start app --data=$DATADIR "\$@"
EOF

# fix systemd service to use /var/lib/portmaster for data
subst "s|--data /opt/safing/portmaster|--data $DATADIR|g" $BUILDROOT/lib/systemd/system/portmaster.service
subst "s|PIDFile=/opt/safing/portmaster|PIDFile=$DATADIR|" $BUILDROOT/lib/systemd/system/portmaster.service

# download components at repack time
echo "Downloading components ..."
.$PRODUCTDIR/portmaster-start --data $BUILDROOT$DATADIR update || fatal

p="$(basename $(dirname $BUILDROOT$DATADIR/updates/linux_amd64/app/portmaster-app_v*/chrome-sandbox))"
fix_chrome_sandbox $DATADIR/updates/linux_amd64/app/$p/chrome-sandbox

# block runtime auto-updates: replace portmaster-start with wrapper
mv $BUILDROOT$PRODUCTDIR/portmaster-start $BUILDROOT$PRODUCTDIR/portmaster-start.real
cat <<'WRAPPER' | create_exec_file $PRODUCTDIR/portmaster-start
#!/bin/sh
case "$1" in
    update)
        echo "Auto-update is disabled in the packaged version. Update via: epm play portmaster"
        exit 0
        ;;
esac
exec /opt/safing/portmaster/portmaster-start.real "$@"
WRAPPER

# portmaster-start initializes logs dir even in app mode
mkdir -p $BUILDROOT$DATADIR/logs
pack_file $DATADIR

add_electron_deps
