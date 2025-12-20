#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=discord
PRODUCTCUR=Discord
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

move_to_opt


add_electron_deps

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
CONFIG_DIR="\$HOME"/.config/discord
SETTINGS_FILE="\$CONFIG_DIR"/settings.json
DISCORD_CONFIG_FILE="\$HOME/.config/eepm/discord"
EXTRA_PARAMS=""

if [ ! -f "\$DISCORD_CONFIG_FILE" ]; then
    DISCORD_CONFIG_FILE="/etc/eepm/config/discord"
fi

if [ -f "\$DISCORD_CONFIG_FILE" ]; then
    EXTRA_PARAMS=$(cat "\$DISCORD_CONFIG_FILE")
fi

if [ ! -f "\$SETTINGS_FILE" ]; then
    mkdir -p "\$CONFIG_DIR"
    echo '{ "SKIP_HOST_UPDATE": true}' > "\$SETTINGS_FILE"
fi
exec $PRODUCTDIR/$PRODUCTCUR \$EXTRA_PARAMS "\$@"
EOF
add_bin_link_command $PRODUCTCUR $PRODUCT

rm usr/share/applications/discord.desktop
install_file $PRODUCTDIR/discord.desktop /usr/share/applications/discord.desktop
rm usr/share/pixmaps/discord.png
install_file $PRODUCTDIR/discord.png /usr/share/pixmaps/discord.png

fix_desktop_file /usr/share/discord/Discord $PRODUCT
