#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=discord
PRODUCTCUR=Discord
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

# The official deb only ships updater_bootstrap; the actual Discord binary is
# downloaded by it on first launch into ~/.config/discord/. Run the bootstrap
# now (during repack) so the resulting package contains the binary itself.

bootstrap="$BUILDROOT/usr/share/discord/updater_bootstrap"
[ -x "$bootstrap" ] || fatal "updater_bootstrap not found in $BUILDROOT/usr/share/discord/"

bootstrap_out="$(mktemp -d)"
app_dir="$("$bootstrap" --no-zenity "$bootstrap_out" stable 2>&1 | tail -n1)"
[ -d "$bootstrap_out/$app_dir" ] || fatal "updater_bootstrap failed: app_dir=$app_dir"
[ -x "$bootstrap_out/$app_dir/Discord" ] || fatal "Discord binary missing in $bootstrap_out/$app_dir/"

# Copy extracted Discord files alongside the deb's existing /usr/share/discord/.
# Skip discord.png/discord.desktop already present from the deb (deb's are slightly different).
for f in "$bootstrap_out/$app_dir"/* ; do
    name="$(basename "$f")"
    [ -e "$BUILDROOT/usr/share/discord/$name" ] && continue
    cp -a "$f" "$BUILDROOT/usr/share/discord/"
done
rm -rf "$bootstrap_out"

# Pack every file/symlink in /usr/share/discord/ into the spec %files
# (move_to_opt will rewrite paths to /opt/discord/ later).
find "$BUILDROOT/usr/share/discord" \( -type f -o -type l \) | sed -e "s|^$BUILDROOT||" \
    | while read path ; do pack_file "$path" ; done

move_to_opt

# Drop bootstrap — we have a static binary now, no auto-update from package.
remove_file $PRODUCTDIR/updater_bootstrap

add_electron_deps

# Custom launcher — Discord binary is now baked into /opt/discord/.
cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
CONFIG_DIR="\$HOME"/.config/discord
SETTINGS_FILE="\$CONFIG_DIR"/settings.json
DISCORD_CONFIG_FILE="/etc/opt/$PRODUCT/discord.conf"
EXTRA_PARAMS=""

if [ -f "\$DISCORD_CONFIG_FILE" ]; then
    EXTRA_PARAMS=\$(cat "\$DISCORD_CONFIG_FILE")
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
