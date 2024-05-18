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

#disable update checking at discord start
add_bin_exec_command $PRODUCT $PRODUCTDIR/$PRODUCTCUR
add_bin_link_command $PRODUCTCUR $PRODUCT

cat >$BUILDROOT/usr/bin/$PRODUCT <<EOF
#!/bin/sh
CONFIG_DIR="\$HOME"/.config/discord
SETTINGS_FILE="\$CONFIG_DIR"/settings.json

if [ -f "\$SETTINGS_FILE" ] && grep -q '"SKIP_HOST_UPDATE": true' "\$SETTINGS_FILE"; then
	exec $PRODUCTDIR/$PRODUCTCUR "\$@"
else
	mkdir -p "\$CONFIG_DIR"
	echo '{ "SKIP_HOST_UPDATE": true }' > "\$SETTINGS_FILE"

	exec $PRODUCTDIR/$PRODUCTCUR "\$@"
fi
EOF

rm usr/share/applications/discord.desktop
install_file $PRODUCTDIR/discord.desktop /usr/share/applications/discord.desktop
rm usr/share/pixmaps/discord.png
install_file $PRODUCTDIR/discord.png /usr/share/pixmaps/discord.png

fix_desktop_file /usr/share/discord/Discord $PRODUCT
