#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=discord
PRODUCTCUR=Discord
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

# pack.d/discord.sh assembles the complete app with the updater disabled
[ -x "$BUILDROOT$PRODUCTDIR/$PRODUCTCUR" ] || fatal "Discord binary missing in $PRODUCTDIR"
[ -d "$BUILDROOT$PRODUCTDIR/modules/discord_desktop_core" ] || fatal "Discord modules missing in $PRODUCTDIR/modules"

add_electron_deps

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
CONFIG_DIR="\${XDG_CONFIG_HOME:-\$HOME/.config}/discord"
SETTINGS_FILE="\$CONFIG_DIR/settings.json"
DISCORD_CONFIG_FILE="/etc/opt/$PRODUCT/discord.conf"
EXTRA_PARAMS=""

if [ -f "\$DISCORD_CONFIG_FILE" ]; then
    EXTRA_PARAMS=\$(cat "\$DISCORD_CONFIG_FILE")
fi

mkdir -p "\$CONFIG_DIR"

# remove the app copies installed by updater_bootstrap or by the previous package
rm -rf "\$CONFIG_DIR"/app-* "\$CONFIG_DIR/installer.db" "\$CONFIG_DIR/download"
[ -L "\$CONFIG_DIR/$PRODUCTCUR" ] && rm -f "\$CONFIG_DIR/$PRODUCTCUR"

# Discord blocks the start with 'update manually' when a new host version is released
if ! grep -q '[^[:space:]{}]' "\$SETTINGS_FILE" 2>/dev/null ; then
    echo '{ "SKIP_HOST_UPDATE": true }' > "\$SETTINGS_FILE"
elif grep -q '"SKIP_HOST_UPDATE"' "\$SETTINGS_FILE" ; then
    sed -i -e 's|"SKIP_HOST_UPDATE"[[:space:]]*:[[:space:]]*false|"SKIP_HOST_UPDATE": true|' "\$SETTINGS_FILE"
else
    sed -i -e '0,/{/s//{ "SKIP_HOST_UPDATE": true,/' "\$SETTINGS_FILE"
fi

exec $PRODUCTDIR/$PRODUCTCUR \$EXTRA_PARAMS "\$@"
EOF
add_bin_link_command $PRODUCTCUR $PRODUCT

fix_desktop_file /usr/bin/$PRODUCT $PRODUCT
