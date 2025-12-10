#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt /usr/lib/wifiman-desktop
move_file /usr/bin/wifiman-desktop $PRODUCTDIR/wifiman-desktop
move_file $PRODUCTDIR/wifiman-desktop.service /usr/lib/systemd/system/wifiman-desktop.service

subst "s|^ExecStart=.*$|ExecStart=$PRODUCTDIR/wifiman-desktopd|" $BUILDROOT/usr/lib/systemd/system/wifiman-desktop.service

# fix "Error 71 (protocol error) dispatching to Wayland display"
cat <<EOF | create_exec_file "/usr/bin/$PRODUCT"
#!/bin/sh
if [ "\$XDG_SESSION_TYPE" = "wayland" ]; then
    export WEBKIT_DISABLE_DMABUF_RENDERER=1 
fi
exec "$PRODUCTDIR/wifiman-desktop" "\$@"
EOF

add_libs_requires
