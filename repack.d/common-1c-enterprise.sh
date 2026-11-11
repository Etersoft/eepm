#!/bin/sh

info()
{
    echo "$*" >&2
}

warning()
{
    echo "WARNING: $*" >&2
}

__1c_enterprise_add_requires()
{
    ignore_lib_requires \
        'libicudata.so.46()(64bit)' 'libicui18n.so.46()(64bit)' 'libicuuc.so.46()(64bit)' \
        'libnghttp2-v8.so.14()(64bit)' \
        'libwx_gtk3u-3.0.so.*' 'libwx_gtk3u_gl-3.0.so.*' 'libxdiff.so.*'

    if is_soname_present libicudata.so.74 ; then
        add_requires 'libicudata.so.74()(64bit)'
    else
        warning 'System ICU 74 is not found, keeping bundled ICU libraries'
    fi

    if __1c_enterprise_use_wk41 ; then
        ignore_lib_requires 'libwebkit2gtk-4.0.so.*' 'libjavascriptcoregtk-4.0.so.*' 'libsoup-2.4.so.*'
        add_requires 'libwebkit2gtk-4.1.so.0()(64bit)' 'libjavascriptcoregtk-4.1.so.0()(64bit)'
    else
        ignore_lib_requires 'libwebkit2gtk-4.1.so.*' 'libjavascriptcoregtk-4.1.so.*' 'libsoup-3.0.so.*'
        add_requires 'libwebkit2gtk-4.0.so.37()(64bit)' 'libjavascriptcoregtk-4.0.so.18()(64bit)'
    fi
}

__1c_enterprise_use_wk41()
{
    local distrname distrver

    distrname="$(epm print info -d | tr '[:upper:]' '[:lower:]')"
    distrver="$(epm print info -v | cut -d_ -f1)"

    case "$distrname" in
        *stra*)
            [ "$(epm print compare version "$distrver" 1.7)" = 1 ] || return 1
            ;;
        *buntu)
            [ "$(epm print compare version "${distrver%%.*}" 23)" = 1 ] || return 1
            ;;
        *inux*int*)
            [ "$(epm print compare version "${distrver%%.*}" 21)" = 1 ] || return 1
            ;;
        *)
            return 1
            ;;
    esac
}

__1c_enterprise_prepare_wk41()
{
    local versiondir="$1"

    [ -n "$versiondir" ] || return 0
    [ -d "$BUILDROOT$versiondir" ] || return 0
    __1c_enterprise_use_wk41 || return 0

    [ -f "$BUILDROOT$versiondir/libwx_gtk3u-3.0.so.0.1.0.wk41" ] &&
        ln -sfn libwx_gtk3u-3.0.so.0.1.0.wk41 "$BUILDROOT$versiondir/libwx_gtk3u-3.0.so.0"

    [ -f "$BUILDROOT$versiondir/webkit2_extu-3.0.so.wk41" ] &&
        [ -d "$BUILDROOT$versiondir/webkit2ext" ] &&
        ln -sfn ../webkit2_extu-3.0.so.wk41 "$BUILDROOT$versiondir/webkit2ext/webkit2_extu-3.0.so"
}

__1c_enterprise_get_version_dir()
{
    local arch dir
    for arch in x86_64 i586 i386 ; do
        for dir in "$BUILDROOT/opt/1cv8/$arch"/*.*.*.* ; do
            [ -d "$dir" ] || continue
            echo "${dir#$BUILDROOT}"
            return 0
        done
    done
    return 1
}

__1c_enterprise_copy_to_common()
{
    local versiondir="$1"
    local pattern src dest

    [ -n "$versiondir" ] || return 0
    [ -d "$BUILDROOT$versiondir" ] || return 0

    mkdir -p "$BUILDROOT/opt/1cv8/common" || fatal
    pack_dir /opt/1cv8/common

    for pattern in \
        nuke83.so uiproxywx.so core*.so \
        'libwx_gtk3u-3.0.*' 'libwx_gtk3u_gl-3.0.*' 'libicu*' 'libatomic.so.1*' \
        libunwind.so.8 'libtcmalloc.so.4*'
    do
        for src in "$BUILDROOT$versiondir"/$pattern ; do
            [ -e "$src" ] || [ -L "$src" ] || continue
            dest="/opt/1cv8/common/$(basename "$src")"
            cp -a "$src" "$BUILDROOT$dest" || fatal
            pack_file "$dest"
        done
    done
}

__1c_enterprise_prepare_starter()
{
    local versiondir
    local desktop

    versiondir="$(__1c_enterprise_get_version_dir)" || return 0

    __1c_enterprise_prepare_wk41 "$versiondir"
    __1c_enterprise_copy_to_common "$versiondir"

    move_file "$versiondir/1cestart" /opt/1cv8/common/1cestart
    cat <<EOF | create_exec_file /usr/bin/1cestart
#!/bin/sh
export LD_LIBRARY_PATH="$versiondir:/opt/1cv8/common\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec /opt/1cv8/common/1cestart "\$@"
EOF

    for desktop in "$BUILDROOT$versiondir"/1cestart*.desktop ; do
        [ -e "$desktop" ] || [ -L "$desktop" ] || continue
        move_file "${desktop#$BUILDROOT}" /usr/share/applications/1cestart.desktop
        chmod 0644 "$BUILDROOT/usr/share/applications/1cestart.desktop"
        break
    done

    fix_desktop_file /opt/1cv8/common/1cestart 1cestart
}

__1c_enterprise_create_client_command()
{
    local command="$1"
    local versiondir="$2"

    cat <<EOF | create_exec_file "/usr/bin/$command"
#!/bin/sh
export LD_LIBRARY_PATH="$versiondir:/opt/1cv8/common\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "$versiondir/$command" "\$@"
EOF
}

__1c_enterprise_install_server_units()
{
    local versiondir
    local unit

    versiondir="$(__1c_enterprise_get_version_dir)" || return 0

    for unit in "$BUILDROOT$versiondir"/*.service ; do
        [ -e "$unit" ] || [ -L "$unit" ] || continue
        move_file "${unit#$BUILDROOT}" "/usr/lib/systemd/system/$(basename "$unit")"
    done

    cat <<EOF | create_file /usr/lib/sysusers.d/1c-enterprise.conf
g grp1cv8 -
u usr1cv8 - "1C Enterprise 8 server launcher" /home/usr1cv8
m usr1cv8 grp1cv8
EOF

    cat <<EOF | create_file /usr/lib/tmpfiles.d/1c-enterprise.conf
d /home/usr1cv8 0750 usr1cv8 grp1cv8 -
d /var/1C 2775 usr1cv8 grp1cv8 -
d /var/1C/licenses 2775 usr1cv8 grp1cv8 -
EOF
}

__1c_enterprise_installing_client()
{
    local pkgname="$1"

    case "$pkgname" in
        *-thin-client|*-thin-client-nls)
            ;;
        *-client)
            return 0
            ;;
    esac

    return 1
}

__1c_enterprise_remove_thin_client_duplicate_icons()
{
    local icon

    for icon in 1cestart 1cv8c 1cv8s ; do
        remove_file "/usr/share/app-install/icons/$icon-*.png"
        remove_file "/usr/share/icons/hicolor/*x*/apps/$icon.png"
        remove_file "/usr/share/icons/hicolor/*x*/apps/$icon-*.png"
        remove_file "/usr/share/icons/hicolor/scalable/apps/$icon.svg"
        remove_file "/usr/share/icons/hicolor/scalable/apps/$icon-*.svg"
        remove_file "/usr/share/pixmaps/$icon-*.png"
        remove_file "/usr/share/pixmaps/$icon.png"
    done
}

__1c_enterprise_remove_app_install_icons()
{
    remove_dir /usr/share/app-install
}

__1c_enterprise_normalize_icon_name()
{
    local icon="$1"
    local file ext dest

    for file in "$BUILDROOT"/usr/share/icons/hicolor/*x*/apps/"$icon"-* \
        "$BUILDROOT"/usr/share/icons/hicolor/scalable/apps/"$icon"-* \
        "$BUILDROOT"/usr/share/pixmaps/"$icon"-*
    do
        [ -e "$file" ] || [ -L "$file" ] || continue
        ext="${file##*.}"
        dest="$(dirname "${file#"$BUILDROOT"}")/$icon.$ext"
        move_file "${file#"$BUILDROOT"}" "$dest"
    done

    for file in "$BUILDROOT"/usr/share/applications/*.desktop ; do
        [ -f "$file" ] || continue
        subst "s|^Icon=$icon-.*|Icon=$icon|" "$file"
    done
}

__1c_enterprise_normalize_desktop_name()
{
    local command="$1"
    local versiondir="$2"
    local desktop

    [ ! -f "$BUILDROOT/usr/share/applications/$command.desktop" ] || return 0
    for desktop in "$BUILDROOT/usr/share/applications/$command"-*.desktop \
        "$BUILDROOT$versiondir/$command.desktop" "$BUILDROOT$versiondir/$command"-*.desktop ; do
        [ -e "$desktop" ] || [ -L "$desktop" ] || continue
        move_file "${desktop#$BUILDROOT}" "/usr/share/applications/$command.desktop"
        chmod 0644 "$BUILDROOT/usr/share/applications/$command.desktop"
        break
    done
}

__1c_enterprise_remove_uninstall_desktop_files()
{
    local versiondir="$1"
    local file

    remove_file "/usr/share/applications/*uninstall*.desktop"
    [ -n "$versiondir" ] && remove_file "$versiondir/*uninstall*.desktop"
    remove_file "/usr/share/icons/hicolor/*/apps/*uninstall*"
    remove_file "/usr/share/pixmaps/*uninstall*"

    [ -n "$versiondir" ] || return 0

    for file in "$BUILDROOT$versiondir"/uninstall* "$BUILDROOT$versiondir"/uninstaller-* ; do
        [ -e "$file" ] || [ -L "$file" ] || continue
        remove_file "${file#$BUILDROOT}"
    done
}

__1c_enterprise_prepare_client_desktop()
{
    local versiondir
    local command

    versiondir="$(__1c_enterprise_get_version_dir)" || return 0

    for command in 1cestart 1cv8 1cv8c 1cv8s ; do
        __1c_enterprise_normalize_icon_name "$command"
    done

    for command in 1cv8 1cv8c 1cv8s ; do
        [ -x "$BUILDROOT$versiondir/$command" ] || continue
        __1c_enterprise_normalize_desktop_name "$command" "$versiondir"
        __1c_enterprise_create_client_command "$command" "$versiondir"
        fix_desktop_file "$versiondir/$command" "$command"
    done

    __1c_enterprise_remove_app_install_icons
}

__1c_enterprise_remove_deb_client_postinst_actions()
{
    local postinst="$BUILDROOT/DEBIAN/postinst"

    [ -f "$postinst" ] || return 0

    sed -i '/^# "conf" directory$/,$d' "$postinst"
}

fix_1c_enterprise_package()
{
    local pkgname="$1"

    case "$pkgname" in
        *-client|*-thin-client|*-server)
            __1c_enterprise_add_requires
            ;;
    esac

    case "$pkgname" in
        *-client|*-thin-client)
            __1c_enterprise_prepare_starter
            __1c_enterprise_prepare_client_desktop
            __1c_enterprise_remove_deb_client_postinst_actions
            ;;
        *-server)
            __1c_enterprise_install_server_units
            ;;
    esac

    case "$pkgname" in
        *-thin-client)
            __1c_enterprise_remove_thin_client_duplicate_icons "$pkgname"
            ;;
    esac

    # Keep the vendor runtime: host-library versions alone do not prove ABI/arch compatibility.
    true
}
