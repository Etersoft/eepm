#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar
PRODUCTDIR=opt/eepm-wine/$PRODUCT

mkdir -p "$PRODUCTDIR"
cp "$TAR" "$PRODUCTDIR/Affinity-x64.exe" || fatal
printf '%s\n' "$VERSION" >"$PRODUCTDIR/build"

cat <<'EOF' >"$PRODUCTDIR/setup.sh"
#!/bin/sh
set -eu

PRODUCTDIR=/opt/eepm-wine/affinity3
SCHEMA=1
AFFINITY_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/eepm-wine/affinity3"
PREFIX="$AFFINITY_HOME/prefix"
RUNTIME="$AFFINITY_HOME/runtime"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/eepm-wine/affinity3"
STATE="$AFFINITY_HOME/state"
LOG="$AFFINITY_HOME/setup.log"
LOCK="$AFFINITY_HOME/setup.lock"
INSTALLER="$PRODUCTDIR/Affinity-x64.exe"
PACKAGE_BUILD="$(cat "$PRODUCTDIR/build" 2>/dev/null || true)"
AFFINITY_DIR="$PREFIX/drive_c/Program Files/Affinity/Affinity"
AFFINITY_EXE="$AFFINITY_DIR/Affinity.exe"
# Affinity requires the patched Wine build used by the upstream Linux setup.
WINE_URL="https://github.com/ryzendew/Affinity-Wine-Builder/releases/download/11.12/ElementalWarrior-wine-11.12-v4.tar.xz"
WINE_ARCHIVE="$CACHE/ElementalWarrior-wine-11.12-v4.tar.xz"
WINE_SHA256="50eba5aa5f293fb6718a1862dd854f5087884dc9f2b6c32a7f8fb46e97f42843"
# Affinity v3 registry and application settings for Wine.
SETTINGS_URL="https://github.com/seapear/AffinityOnLinux/archive/refs/heads/main.zip"
# PluginLoader and WineFix provide the preferred Affinity launch hook.
PLUGIN_API="https://api.github.com/repos/noahc3/AffinityPluginLoader/releases/latest"
# VKD3D-Proton supplies native D3D12 support for the Wine prefix.
VKD3D_API="https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases/latest"
# Prebuilt patcher fixes Affinity v3 settings persistence.
PATCHER_SOURCE="https://github.com/ryzendew/AffinityOnLinux/archive/refs/heads/main.zip"

mkdir -p "$AFFINITY_HOME" "$CACHE" "$STATE"
touch "$LOG"
exec 3>&1
exec >>"$LOG" 2>&1

say()
{
    printf '%s\n' "$*" >&3
    printf '%s\n' "$*"
}

fatal()
{
    say "Affinity setup failed: $*"
    say "See $LOG for details."
    exit 1
}

have()
{
    command -v "$1" >/dev/null 2>&1
}

download()
{
    url="$1"
    dest="$2"
    tmp="$dest.part"
    rm -f "$tmp"
    if have curl ; then
        curl -fsSL --retry 3 --connect-timeout 20 -o "$tmp" "$url" || return 1
    elif have wget ; then
        wget -q -O "$tmp" "$url" || return 1
    else
        return 1
    fi
    [ -s "$tmp" ] || return 1
    mv -f "$tmp" "$dest" || return 1
}

verify_sha256()
{
    file="$1"
    expected="$2"
    actual="$(sha256sum "$file" | cut -d ' ' -f 1)" || return 1
    [ "$actual" = "$expected" ]
}

file_sha256()
{
    sha256sum "$1" | cut -d ' ' -f 1
}

extract_zip()
{
    archive="$1"
    destination="$2"
    mkdir -p "$destination"
    if have unzip ; then
        unzip -oq "$archive" -d "$destination" || return 1
    elif have 7z ; then
        7z x -y -o"$destination" "$archive" >/dev/null || return 1
    else
        return 1
    fi
}

release_asset_url()
{
    api="$1"
    pattern="$2"
    json=
    if have curl ; then
        json="$(curl -fsL -H 'User-Agent: eepm-affinity3' "$api")" || return 1
    else
        json="$(wget -qO- --header='User-Agent: eepm-affinity3' "$api")" || return 1
    fi
    printf '%s\n' "$json" | epm --inscript --quiet tool json -b \
        | grep '"browser_download_url"' \
        | sed -e 's|.*[[:space:]]||' -e 's|"||g' \
        | grep -Ei "$pattern" | head -n1
}

cleanup()
{
    rm -rf "$LOCK"
}

lock_is_stale()
{
    [ -r "$LOCK/pid" ] || return 0
    pid="$(cat "$LOCK/pid" 2>/dev/null || true)"
    [ -n "$pid" ] || return 0
    kill -0 "$pid" 2>/dev/null && return 1
    return 0
}

[ "$(id -u)" -ne 0 ] || fatal "run affinity as a regular user, not root"
[ "$(uname -m)" = "x86_64" ] || fatal "only x86_64 is supported"
[ -r "$INSTALLER" ] || fatal "packaged Affinity installer is missing"
[ -n "$PACKAGE_BUILD" ] || fatal "packaged Affinity build is missing"

for cmd in epm dotnet winetricks tar xz zstd ; do
    have "$cmd" || fatal "$cmd is required; reinstall with epm play affinity3"
done

if ! mkdir "$LOCK" 2>/dev/null ; then
    if lock_is_stale ; then
        rm -rf "$LOCK"
        mkdir "$LOCK" || fatal "cannot recreate stale setup lock"
    else
        fatal "another Affinity setup is already running"
    fi
fi
printf '%s\n' "$$" >"$LOCK/pid"
trap cleanup EXIT

say "Affinity first-run setup"
say "Data: $AFFINITY_HOME"

if [ ! -x "$RUNTIME/bin/wine" ] ; then
    say "Downloading ElementalWarrior Wine 11.12..."
    [ -s "$WINE_ARCHIVE" ] || download "$WINE_URL" "$WINE_ARCHIVE" || fatal "cannot download ElementalWarrior Wine"
    # Verify the cached archive too, so a partial or replaced download is never used.
    verify_sha256 "$WINE_ARCHIVE" "$WINE_SHA256" || fatal "ElementalWarrior Wine checksum verification failed"
    temp_runtime="$AFFINITY_HOME/runtime.new"
    rm -rf "$temp_runtime"
    mkdir -p "$temp_runtime"
    xz -dc "$WINE_ARCHIVE" | tar -xf - -C "$temp_runtime"
    extracted=
    for candidate in "$temp_runtime"/*/bin/wine "$temp_runtime"/bin/wine ; do
        [ -f "$candidate" ] || continue
        extracted="$candidate"
        break
    done
    [ -n "$extracted" ] || fatal "Wine archive does not contain bin/wine"
    extracted="${extracted%/bin/wine}"
    rm -rf "$RUNTIME"
    mv "$extracted" "$RUNTIME"
    rm -rf "$temp_runtime"
fi

WINE="$RUNTIME/bin/wine"
WINESERVER="$RUNTIME/bin/wineserver"
REGEDIT="$RUNTIME/bin/regedit"
WINECFG="$RUNTIME/bin/winecfg"
export WINEPREFIX="$PREFIX"
export WINEDEBUG="-all,fixme-all"
export WINETRICKS_GUI=none
export WINEDLLOVERRIDES="winemenubuilder.exe=d"
# Let winetricks use the bundled Wine binaries instead of system Wine.
export PATH="$RUNTIME/bin:$PATH"

if [ ! -f "$STATE/prefix" ] ; then
    say "Creating isolated Wine prefix..."
    mkdir -p "$PREFIX"
    "$WINE" wineboot -u
    "$WINESERVER" -w
    touch "$STATE/prefix"
fi

if [ ! -f "$STATE/winetricks" ] ; then
    say "Installing required Wine components. This can take a long time..."
    for component in dotnet35sp1 dotnet48 corefonts vcrun2022 msxml3 msxml6 tahoma crypt32 renderer=vulkan ; do
        say "Installing $component..."
        winetricks --unattended --force --no-isolate --optout "$component" || fatal "winetricks failed on $component"
    done
    "$WINECFG" -v win11
    theme="$CACHE/wine-dark-theme.reg"
    download "https://raw.githubusercontent.com/seapear/AffinityOnLinux/refs/heads/main/Auxiliary/Other/wine-dark-theme.reg" "$theme" || fatal "cannot download Wine theme"
    "$REGEDIT" "$theme" || true
    touch "$STATE/winetricks"
fi

if [ ! -f "$STATE/vkd3d" ] ; then
    say "Installing vkd3d-proton D3D12 support..."
    vkd3d_url="$(release_asset_url "$VKD3D_API" 'vkd3d-proton-.*\.tar\.zst$')"
    [ -n "$vkd3d_url" ] || fatal "cannot resolve latest vkd3d-proton release"
    vkd3d_archive="$CACHE/vkd3d-proton.tar.zst"
    download "$vkd3d_url" "$vkd3d_archive" || fatal "cannot download vkd3d-proton"
    vkd3d_tmp="$AFFINITY_HOME/vkd3d.new"
    rm -rf "$vkd3d_tmp"
    mkdir -p "$vkd3d_tmp"
    zstd -dc "$vkd3d_archive" | tar -xf - -C "$vkd3d_tmp"
    d3d12=
    d3d12core=
    for candidate in "$vkd3d_tmp"/*/x64/d3d12.dll "$vkd3d_tmp"/x64/d3d12.dll ; do
        [ -f "$candidate" ] || continue
        d3d12="$candidate"
        d3d12core="${candidate%/d3d12.dll}/d3d12core.dll"
        break
    done
    [ -n "$d3d12" ] && [ -n "$d3d12core" ] || fatal "vkd3d archive layout is unsupported"
    mkdir -p "$PREFIX/drive_c/windows/system32"
    cp "$d3d12" "$d3d12core" "$PREFIX/drive_c/windows/system32/"
    # Prefer the copied VKD3D DLLs over Wine's built-in D3D12 implementation.
    cat >"$AFFINITY_HOME/vkd3d.reg" <<'REGEOF'
REGEDIT4
[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"d3d12"="native"
"d3d12core"="native"
REGEOF
    "$REGEDIT" "$AFFINITY_HOME/vkd3d.reg"
    rm -rf "$vkd3d_tmp"
    touch "$STATE/vkd3d"
fi

installed_build="$(cat "$STATE/installed-build" 2>/dev/null || true)"
if [ ! -f "$AFFINITY_EXE" ] || [ "$PACKAGE_BUILD" != "$installed_build" ] ; then
    if [ -f "$AFFINITY_EXE" ] ; then
        say "Updating Affinity to build $PACKAGE_BUILD..."
        "$WINESERVER" -k || true
        "$WINESERVER" -w || true
    else
        say "Launching the official Affinity installer..."
    fi
    "$WINECFG" -v win11
    "$WINE" "$INSTALLER" || true
    "$WINESERVER" -w || true
    [ -f "$AFFINITY_EXE" ] || fatal "Affinity was not installed; run affinity again to retry"
    # The package supplies a desktop entry; remove the duplicate Wine shortcut.
    rm -f "${XDG_DESKTOP_DIR:-$HOME/Desktop}/Affinity.lnk" "$HOME/Рабочий стол/Affinity.lnk"
    printf '%s\n' "$PACKAGE_BUILD" >"$STATE/installed-build"
fi

target_dll="$AFFINITY_DIR/Serif.Affinity.dll"
[ -f "$target_dll" ] || fatal "Affinity settings DLL is missing"
dll_sha256="$(file_sha256 "$target_dll")" || fatal "cannot checksum Affinity settings DLL"
patched_sha256="$(cat "$STATE/patched-dll.sha256" 2>/dev/null || true)"
dll_changed=0

if [ "$dll_sha256" != "$patched_sha256" ] ; then
    dll_changed=1
    say "Applying the Affinity v3 settings patch..."
    patcher_zip="$CACHE/AffinityOnLinux-patcher.zip"
    patcher_tmp="$AFFINITY_HOME/patcher.new"
    patcher_dir=
    download "$PATCHER_SOURCE" "$patcher_zip" || fatal "cannot download AffinityPatcher sources"
    rm -rf "$patcher_tmp"
    extract_zip "$patcher_zip" "$patcher_tmp" || fatal "cannot extract AffinityPatcher sources"
    for candidate in "$patcher_tmp"/*/Patch/AffinityPatcherSettings ; do
        [ -f "$candidate/AffinityPatcher.csproj" ] || continue
        patcher_dir="$candidate"
        break
    done
    [ -f "$patcher_dir/AffinityPatcher.csproj" ] || fatal "AffinityPatcher project is missing"
    patcher_output="$patcher_dir/bin/Release"
    patcher_dll="$patcher_output/AffinityPatcher.dll"
    # Use the upstream prebuilt patcher to avoid a local NuGet restore and SDK dependency.
    [ -f "$patcher_dll" ] || fatal "AffinityPatcher runtime is missing"
    dotnet "$patcher_dll" "$target_dll" || fatal "AffinityPatcher failed"
    patched_sha256="$(file_sha256 "$target_dll")" || fatal "cannot checksum patched Affinity settings DLL"
    rm -rf "$patcher_tmp"
    printf '%s\n' "$patched_sha256" >"$STATE/patched-dll.sha256"
fi

if [ ! -f "$STATE/settings" ] ; then
    say "Installing Affinity v3 settings..."
    settings_zip="$CACHE/AffinityOnLinux-main.zip"
    download "$SETTINGS_URL" "$settings_zip" || fatal "cannot download Affinity v3 settings"
    settings_tmp="$AFFINITY_HOME/settings.new"
    rm -rf "$settings_tmp"
    extract_zip "$settings_zip" "$settings_tmp" || fatal "cannot extract Affinity v3 settings"
    settings_source=
    for candidate in "$settings_tmp"/*/Auxiliary/Settings/Affinity/3.0/Settings ; do
        [ -d "$candidate" ] || continue
        settings_source="$candidate"
        break
    done
    if [ -n "$settings_source" ] ; then
        user_dir=
        for candidate in "$PREFIX/drive_c/users"/* ; do
            [ -d "$candidate" ] || continue
            case "${candidate##*/}" in
                Public|Default|'All Users'|'Default User') continue ;;
            esac
            user_dir="$candidate"
            break
        done
        [ -n "$user_dir" ] || user_dir="$PREFIX/drive_c/users/Public"
        settings_dest="$user_dir/AppData/Roaming/Affinity/Affinity/3.0/Settings"
        mkdir -p "$(dirname "$settings_dest")"
        if [ ! -d "$settings_dest" ] ; then
            cp -R "$settings_source" "$settings_dest"
        else
            say "Keeping existing Affinity v3 settings."
        fi
        touch "$STATE/settings"
    else
        say "Warning: Affinity v3 settings were not found in the upstream archive."
    fi
    rm -rf "$settings_tmp"
fi

if [ ! -f "$STATE/plugin-loader" ] || [ "$dll_changed" -eq 1 ] ; then
    say "Installing AffinityPluginLoader and WineFix..."
    loader_url="$(release_asset_url "$PLUGIN_API" 'affinitypluginloader-.*\.zip$' || true)"
    winefix_url="$(release_asset_url "$PLUGIN_API" '(apl-winefix-|winefix).*\.zip$' || true)"
    if [ -n "$loader_url" ] && [ -n "$winefix_url" ] ; then
        loader_zip="$CACHE/affinitypluginloader.zip"
        winefix_zip="$CACHE/apl-winefix.zip"
        if download "$loader_url" "$loader_zip" && download "$winefix_url" "$winefix_zip" ; then
            if extract_zip "$loader_zip" "$AFFINITY_DIR" && extract_zip "$winefix_zip" "$AFFINITY_DIR" ; then
                if [ -f "$AFFINITY_DIR/AffinityHook.exe" ] ; then
                    touch "$STATE/plugin-loader"
                else
                    say "Warning: AffinityHook.exe is missing; Affinity.exe will be used."
                fi
            else
                say "Warning: PluginLoader extraction failed; Affinity.exe will be used."
            fi
        else
            say "Warning: PluginLoader download failed; Affinity.exe will be used."
        fi
    else
        say "Warning: PluginLoader release assets could not be resolved; continuing without the hook."
    fi
fi

printf '%s\n' "$SCHEMA" >"$STATE/schema"
say "Affinity setup completed."
EOF

cat <<'EOF' >"$PRODUCTDIR/run.sh"
#!/bin/sh
set -eu

PRODUCTDIR=/opt/eepm-wine/affinity3
AFFINITY_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/eepm-wine/affinity3"
PREFIX="$AFFINITY_HOME/prefix"
RUNTIME="$AFFINITY_HOME/runtime"
STATE="$AFFINITY_HOME/state"
AFFINITY_DIR="$PREFIX/drive_c/Program Files/Affinity/Affinity"
HOOK="$AFFINITY_DIR/AffinityHook.exe"
APP="$AFFINITY_DIR/Affinity.exe"

show_error()
{
    message="$1"
    backend="$(dialog_backend)"
    if [ "$backend" = "kdialog" ] ; then
        kdialog --title="Affinity setup" --error "$message" >/dev/null 2>&1 || true
    elif [ "$backend" = "zenity" ] ; then
        zenity --error --title="Affinity setup" --width=520 --text="$message" >/dev/null 2>&1 || true
    else
        printf '%s\n' "$message" >&2
    fi
}

dialog_backend()
{
    [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] || return
    case "${XDG_CURRENT_DESKTOP:-}${DESKTOP_SESSION:-}" in
        *KDE*|*Plasma*|*plasma*)
            command -v kdialog >/dev/null 2>&1 && { printf '%s\n' kdialog; return; }
            ;;
    esac
    command -v zenity >/dev/null 2>&1 && { printf '%s\n' zenity; return; }
    command -v kdialog >/dev/null 2>&1 && printf '%s\n' kdialog
}

run_setup()
{
    backend="$(dialog_backend)"
    if [ -z "$backend" ] ; then
        "$PRODUCTDIR/setup.sh"
        return
    fi

    mkdir -p "$AFFINITY_HOME"
    if [ "$backend" = "kdialog" ] ; then
        kdialog --title="Affinity setup" --progressbar "Preparing Affinity for the first launch. This may take a long time..." 0 &
    else
        zenity --progress \
            --title="Affinity setup" \
            --text="Preparing Affinity for the first launch. This may take a long time..." \
            --pulsate \
            --auto-close \
            --no-cancel \
            --width=560 </dev/null &
    fi
    progress_pid=$!

    setup_status=0
    "$PRODUCTDIR/setup.sh" || setup_status=$?

    kill "$progress_pid" 2>/dev/null || true
    wait "$progress_pid" 2>/dev/null || true

    if [ "$setup_status" -ne 0 ] ; then
        show_error "Affinity setup did not complete.\n\nDetails: $AFFINITY_HOME/setup.log"
        return "$setup_status"
    fi
}

if [ ! -x "$RUNTIME/bin/wine" ] || [ ! -f "$APP" ] || [ "$(cat "$STATE/schema" 2>/dev/null || true)" != "1" ] ; then
    run_setup
fi

if [ -f "$HOOK" ] ; then
    RUNFILE="$HOOK"
else
    RUNFILE="$APP"
fi

[ -f "$RUNFILE" ] || { echo "Affinity executable was not found. Run affinity3-setup." >&2; exit 1; }

export WINEPREFIX="$PREFIX"
export WINEDEBUG="-all,fixme-all"
export WINEDLLOVERRIDES="winemenubuilder.exe=d"
exec "$RUNTIME/bin/wine" "$RUNFILE" "$@"
EOF

chmod 755 "$PRODUCTDIR/setup.sh" "$PRODUCTDIR/run.sh"
erc pack "$PKGNAME" opt/eepm-wine || fatal
return_tar "$PKGNAME"
