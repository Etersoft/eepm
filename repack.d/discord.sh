#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=discord
PRODUCTCUR=Discord
PRODUCTDIR=/opt/$PRODUCT
CHANNEL=stable
DOWNLOAD=https://updates.discord.com/

. $(dirname $0)/common-chromium-browser.sh

# The official deb only ships updater_bootstrap; the actual Discord binary is
# downloaded by it on first launch into ~/.config/discord/. Run the bootstrap
# now (during repack) so the resulting package contains the binary itself.

bootstrap="$BUILDROOT/usr/share/discord/updater_bootstrap"
[ -x "$bootstrap" ] || fatal "updater_bootstrap not found in $BUILDROOT/usr/share/discord/"

bootstrap_out="$(mktemp -d)"
app_dir="$("$bootstrap" --no-zenity "$bootstrap_out" "$CHANNEL" "$DOWNLOAD")" || fatal "updater_bootstrap failed"
[ -d "$bootstrap_out/$app_dir" ] || fatal "updater_bootstrap failed: app_dir=$app_dir"
[ -x "$bootstrap_out/$app_dir/Discord" ] || fatal "Discord binary missing in $bootstrap_out/$app_dir/"
[ -f "$bootstrap_out/installer.db" ] || fatal "Discord installer database missing in $bootstrap_out/"
[ -d "$bootstrap_out/$app_dir/modules" ] || fatal "Discord modules missing in $bootstrap_out/$app_dir/"

# Preserve the updater_bootstrap layout: installer.db must stay next to app-*,
# and native modules live under app-*/modules.
cp -a "$bootstrap_out/$app_dir" "$BUILDROOT/usr/share/discord/"
cp -a "$bootstrap_out/installer.db" "$BUILDROOT/usr/share/discord/"

rm -rf "$bootstrap_out"

# Pack every file/symlink in /usr/share/discord/ into the spec %files
# (move_to_opt will rewrite paths to /opt/discord/ later).
find "$BUILDROOT/usr/share/discord" \( -type f -o -type l \) | sed -e "s|^$BUILDROOT||" \
    | while read path ; do pack_file "$path" ; done

move_to_opt

# Drop bootstrap — we have a static binary now, no auto-update from package.
remove_file $PRODUCTDIR/updater_bootstrap

add_electron_deps

# Custom launcher — Discord binary is now baked into /opt/discord/app-*/.
cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
CONFIG_DIR="\$HOME"/.config/discord
SETTINGS_FILE="\$CONFIG_DIR"/settings.json
DISCORD_CONFIG_FILE="/etc/opt/$PRODUCT/discord.conf"
APP_DIR="$app_dir"
SYSTEM_APP_DIR="$PRODUCTDIR/$app_dir"
USER_APP_DIR="\$CONFIG_DIR/\$APP_DIR"
EXTRA_PARAMS=""

if [ -f "\$DISCORD_CONFIG_FILE" ]; then
    EXTRA_PARAMS=\$(cat "\$DISCORD_CONFIG_FILE")
fi

mkdir -p "\$CONFIG_DIR"

if [ ! -x "\$USER_APP_DIR/$PRODUCTCUR" ] || [ ! -d "\$USER_APP_DIR/modules" ] || [ ! -f "\$CONFIG_DIR/installer.db" ]; then
    rm -rf "\$USER_APP_DIR.tmp"
    cp -a "\$SYSTEM_APP_DIR" "\$USER_APP_DIR.tmp" || exit
    rm -rf "\$USER_APP_DIR"
    mv "\$USER_APP_DIR.tmp" "\$USER_APP_DIR" || exit
    cp -a "$PRODUCTDIR/installer.db" "\$CONFIG_DIR/installer.db" || exit
fi

for old_app_dir in "\$CONFIG_DIR"/app-* ; do
    [ "\$old_app_dir" = "\$USER_APP_DIR" ] && continue
    [ -d "\$old_app_dir" ] && rm -rf "\$old_app_dir"
done

if [ ! -f "\$SETTINGS_FILE" ]; then
    echo '{ "SKIP_HOST_UPDATE": true}' > "\$SETTINGS_FILE"
fi
exec "\$USER_APP_DIR/$PRODUCTCUR" \$EXTRA_PARAMS "\$@"
EOF
add_bin_link_command $PRODUCTCUR $PRODUCT

rm usr/share/applications/discord.desktop
install_file $PRODUCTDIR/discord.desktop /usr/share/applications/discord.desktop
rm usr/share/pixmaps/discord.png
install_file $PRODUCTDIR/discord.png /usr/share/pixmaps/discord.png

fix_desktop_file /usr/bin/discord $PRODUCT
