#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

PRODUCTDIR=/opt/davinci-resolve
REMOTE_MONITOR="$PRODUCTDIR/bin/DaVinci Remote Monitor"

# DaVinci Resolve Studio 21.1 renamed the remote monitor binary.
[ -f "$BUILDROOT$PRODUCTDIR/bin/Blackmagic Remote Monitor" ] && \
	REMOTE_MONITOR="$PRODUCTDIR/bin/Blackmagic Remote Monitor"

if echo "$PRODUCT" | grep -q "Studio"; then
	add_conflicts davinci-resolve
else
	add_conflicts davinci-resolve-Studio
fi

# Legacy 32-bit LUT tools duplicate otherwise 64-bit system requirements.
ignore_library_path "$PRODUCTDIR/LUT"

# Optional Onboarding plugins refer to Qt modules that are not bundled and are
# not needed by Resolve itself.
ignore_library_path "$PRODUCTDIR/Onboarding/qml/QtQml/RemoteObjects"
ignore_library_path "$PRODUCTDIR/Onboarding/qml/QtQuick/Particles.2"
ignore_library_path "$PRODUCTDIR/Onboarding/qml/QtQuick/Shapes"
ignore_library_path "$PRODUCTDIR/Onboarding/qml/QtQuick/VirtualKeyboard"

# CUDA is an optional backend; libQtGui.so.4 is an unused legacy bundled copy.
ignore_lib_requires libcuda.so.1 libpng12.so.0 libstdc++-libc6.2-2.so.3 libstdc++.so.5

add_bin_exec_command davinci-resolve "$PRODUCTDIR/bin/resolve"
add_bin_exec_command blackmagicrawplayer "$PRODUCTDIR/BlackmagicRAWPlayer/BlackmagicRAWPlayer"
add_bin_exec_command blackmagicrawspeedtest "$PRODUCTDIR/BlackmagicRAWSpeedTest/BlackmagicRAWSpeedTest"
add_bin_exec_command davinci_control_panels_setup "$PRODUCTDIR/DaVinci Control Panels Setup/DaVinci Control Panels Setup"
add_bin_exec_command davinci-resolve-capture-logs "$PRODUCTDIR/scripts/script.getlogs.v4"

if [ -f "$BUILDROOT$REMOTE_MONITOR" ] ; then
	add_bin_exec_command davinci-remote-monitor "$REMOTE_MONITOR"
fi

# Create directory for Apple Immersive Calibration
mkdir -p "$BUILDROOT/opt/davinci-resolve/Apple Immersive/Calibration"
pack_dir "/opt/davinci-resolve/Apple Immersive"
pack_dir "/opt/davinci-resolve/Apple Immersive/Calibration"

# Resolve 21.1 exits if this application support path cannot be created in /opt.
mkdir -p "$BUILDROOT$PRODUCTDIR/Immersive/Canon/STMap"
pack_dir "$PRODUCTDIR/Immersive"
pack_dir "$PRODUCTDIR/Immersive/Canon"
pack_dir "$PRODUCTDIR/Immersive/Canon/STMap"

# Install icons for applications
install_file $PRODUCTDIR/graphics/DV_Resolve.png /usr/share/icons/hicolor/64x64/apps/davinci-resolve.png
install_file $PRODUCTDIR/graphics/DV_Panels.png /usr/share/icons/hicolor/64x64/apps/davinci-panels.png
[ -f "$BUILDROOT$PRODUCTDIR/graphics/Remote_Monitoring.png" ] && \
	install_file $PRODUCTDIR/graphics/Remote_Monitoring.png /usr/share/icons/hicolor/64x64/apps/davinci-remote-monitor.png

# Install icons for Blackmagic RAW Player & Speed Test
install_file $PRODUCTDIR/graphics/blackmagicraw-player_48x48_apps.png /usr/share/icons/hicolor/48x48/apps/blackmagicraw-player.png
install_file $PRODUCTDIR/graphics/blackmagicraw-player_256x256_apps.png /usr/share/icons/hicolor/256x256/apps/blackmagicraw-player.png
install_file $PRODUCTDIR/graphics/blackmagicraw-speedtest_48x48_apps.png /usr/share/icons/hicolor/48x48/apps/blackmagicraw-speedtest.png
install_file $PRODUCTDIR/graphics/blackmagicraw-speedtest_256x256_apps.png /usr/share/icons/hicolor/256x256/apps/blackmagicraw-speedtest.png

# Install MIME-type icons for BRAW
install_file $PRODUCTDIR/graphics/application-x-braw-clip_48x48_mimetypes.png /usr/share/icons/hicolor/48x48/mimetypes/application-x-braw-clip.png
install_file $PRODUCTDIR/graphics/application-x-braw-clip_256x256_mimetypes.png /usr/share/icons/hicolor/256x256/mimetypes/application-x-braw-clip.png
install_file $PRODUCTDIR/graphics/application-x-braw-sidecar_48x48_mimetypes.png /usr/share/icons/hicolor/48x48/mimetypes/application-x-braw-sidecar.png
install_file $PRODUCTDIR/graphics/application-x-braw-sidecar_256x256_mimetypes.png /usr/share/icons/hicolor/256x256/mimetypes/application-x-braw-sidecar.png

# Install MIME-type icons for DaVinci Resolve formats
install_file $PRODUCTDIR/graphics/DV_ResolveBin.png /usr/share/icons/hicolor/64x64/mimetypes/application-x-resolvebin.png
install_file $PRODUCTDIR/graphics/DV_ResolveProj.png /usr/share/icons/hicolor/64x64/mimetypes/application-x-resolveproj.png
install_file $PRODUCTDIR/graphics/DV_ResolveTimeline.png /usr/share/icons/hicolor/64x64/mimetypes/application-x-resolvetimeline.png
install_file $PRODUCTDIR/graphics/DV_TemplateBundle.png /usr/share/icons/hicolor/64x64/mimetypes/application-x-resolvetemplatebundle.png
install_file $PRODUCTDIR/graphics/DV_ServerAccess.png /usr/share/icons/hicolor/64x64/mimetypes/application-x-resolvedbkey.png

# Fix desktop file paths - replace absolute paths with icon names and commands
fix_desktop_file "$PRODUCTDIR/bin/resolve" "davinci-resolve"
fix_desktop_file "$PRODUCTDIR/graphics/DV_Resolve.png" "davinci-resolve"

fix_desktop_file "$PRODUCTDIR/DaVinci Control Panels Setup/DaVinci Control Panels Setup" "davinci_control_panels_setup"
fix_desktop_file "$PRODUCTDIR/graphics/DV_Panels.png" "davinci-panels"
fix_desktop_file "$PRODUCTDIR/BlackmagicRAWPlayer/BlackmagicRAWPlayer" "blackmagicrawplayer"
fix_desktop_file "$PRODUCTDIR/BlackmagicRAWSpeedTest/BlackmagicRAWSpeedTest" "blackmagicrawspeedtest"
fix_desktop_file "$PRODUCTDIR/scripts/script.getlogs.v4" "davinci-resolve-capture-logs"
subst 's|^Exec="\([^"]*\)"$|Exec=\1|' "$BUILDROOT/usr/share/applications/DaVinciControlPanelsSetup.desktop"

if [ -f "$BUILDROOT/usr/share/applications/DaVinciRemoteMonitoring.desktop" ] ; then
	fix_desktop_file "$REMOTE_MONITOR" "davinci-remote-monitor"
	fix_desktop_file "$PRODUCTDIR/graphics/Remote_Monitoring.png" "davinci-remote-monitor"
	subst 's|^Exec="\([^"]*\)"$|Exec=\1|' "$BUILDROOT/usr/share/applications/DaVinciRemoteMonitoring.desktop"
fi

MENUFILE="$BUILDROOT/etc/xdg/menus/applications-merged/DaVinciResolve.menu"
subst '/com.blackmagicdesign.resolve-Installer.desktop/d' "$MENUFILE"

# Fix desktop file categories for DaVinci Resolve
fix_desktop_categories() {
	local file_pattern="$1"
	local categories="$2"
	local desktop_file="$BUILDROOT/usr/share/applications/$file_pattern"

	[ -f "$desktop_file" ] || return

	# Check if Categories line exists
	if grep -q "^Categories=" "$desktop_file"; then
		sed -i "s/^Categories=.*/Categories=$categories/" "$desktop_file"
	else
		# Add Categories before the last line or after Icon
		sed -i "/^Icon=/a Categories=$categories" "$desktop_file"
	fi
}

# Apply category fixes to DaVinci Resolve desktop files
fix_desktop_categories "DaVinciResolve.desktop" "AudioVideo;Video;AudioVideoEditing;"
fix_desktop_categories "blackmagicraw-player.desktop" "AudioVideo;Video;Player;"
fix_desktop_categories "blackmagicraw-speedtest.desktop" "AudioVideo;Video;"
fix_desktop_categories "DaVinciControlPanelsSetup.desktop" "Settings;HardwareSettings;"
fix_desktop_categories "DaVinciResolveCaptureLogs.desktop" "System;"

# Remove Uninstall desktop file
remove_file /usr/share/applications/DaVinciResolveInstaller.desktop

# The standalone installer gives the shipped desktop files these IDs.  The
# DaVinci Resolve submenu refers to the same names.
move_file /usr/share/applications/DaVinciResolve.desktop /usr/share/applications/com.blackmagicdesign.resolve.desktop
move_file /usr/share/applications/DaVinciResolveCaptureLogs.desktop /usr/share/applications/com.blackmagicdesign.resolve-CaptureLogs.desktop
move_file /usr/share/applications/DaVinciControlPanelsSetup.desktop /usr/share/applications/com.blackmagicdesign.resolve-Panels.desktop
move_file /usr/share/applications/DaVinciRemoteMonitoring.desktop /usr/share/applications/com.blackmagicdesign.resolve-DaVinciRemoteMonitoring.desktop
move_file /usr/share/applications/blackmagicraw-player.desktop /usr/share/applications/com.blackmagicdesign.rawplayer.desktop
move_file /usr/share/applications/blackmagicraw-speedtest.desktop /usr/share/applications/com.blackmagicdesign.rawspeedtest.desktop
move_file /usr/share/desktop-directories/DaVinciResolve.directory /usr/share/desktop-directories/com.blackmagicdesign.resolve.directory
move_file /etc/xdg/menus/applications-merged/DaVinciResolve.menu /etc/xdg/menus/applications-merged/com.blackmagicdesign.resolve.menu
