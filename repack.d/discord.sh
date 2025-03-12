#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=discord
PRODUCTCUR=Discord
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

move_to_opt

fix_chrome_sandbox

add_electron_deps

rm usr/bin/$PRODUCT

mkdir -p $BUILDROOT/usr/bin
cat <<EOF >$BUILDROOT/usr/bin/$PRODUCT
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

if [ -f "\$SETTINGS_FILE" ] && grep -q '"SKIP_HOST_UPDATE": true' "\$SETTINGS_FILE"; then
    exec $PRODUCTDIR/$PRODUCTCUR \$EXTRA_PARAMS "\$@"
else
    mkdir -p "\$CONFIG_DIR"
    echo '{ "SKIP_HOST_UPDATE": true}' > "\$SETTINGS_FILE"
    exec $PRODUCTDIR/$PRODUCTCUR \$EXTRA_PARAMS "\$@"
fi
EOF
chmod a+x $BUILDROOT/usr/bin/$PRODUCT
pack_file /usr/bin/$PRODUCT

rm usr/share/applications/discord.desktop
install_file $PRODUCTDIR/discord.desktop /usr/share/applications/discord.desktop
rm usr/share/pixmaps/discord.png
install_file $PRODUCTDIR/discord.png /usr/share/pixmaps/discord.png

fix_desktop_file /usr/share/discord/Discord $PRODUCT
