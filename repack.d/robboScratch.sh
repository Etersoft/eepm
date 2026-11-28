#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=robboScratch
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# broken link to /opt/robboscratch3, empty file, desktop shortcut helpers for the postinstall script
remove_file $PRODUCTDIR/robboscratch
remove_file $PRODUCTDIR/0
remove_file $PRODUCTDIR/create_shortcut.sh
remove_file $PRODUCTDIR/remove_shortcut.sh
remove_dir /usr/lib/.build-id

# NW.js SDK tools, not needed to run the app
remove_file $PRODUCTDIR/chromedriver
remove_file $PRODUCTDIR/nwjc

# upstream bash launcher checks the dialout group (it is uucp on ALT) via zenity
remove_file $PRODUCTDIR/robboscratch3
cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
# Robbo devices are USB serial adapters: check the user can access serial ports
for dev in /dev/ttyUSB0 /dev/ttyACM0 /dev/ttyS0 ; do
    [ -c "\$dev" ] || continue
    if [ ! -w "\$dev" ] ; then
        grp="\$(stat -c %G "\$dev")"
        echo "Warning: no write access to \$dev. To use hardware ports add the user to the '\$grp' group: sudo usermod -a -G \$grp \$USER" >&2
    fi
    break
done
exec $PRODUCTDIR/robboscratch3_bin --password-store=basic "\$@"
EOF

add_bin_link_command robbo-scratch $PRODUCT
