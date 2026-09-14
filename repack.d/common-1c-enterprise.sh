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

__1c_enterprise_lib_version()
{
    local file="$1"
    local libname="$2"
    local realfile

    case "$libname" in
        libstdc++.so.6)
            strings "$file" 2>/dev/null | sed -n 's|^GLIBCXX_\([0-9][0-9.]*\)$|\1|p' | sort -V | tail -n1
            ;;
        libgcc_s.so.1)
            strings "$file" 2>/dev/null | sed -n 's|^GCC_\([0-9][0-9.]*\)$|\1|p' | sort -V | tail -n1
            ;;
        libhwy.so.1)
            realfile="$(readlink -f "$file" 2>/dev/null || echo "$file")"
            basename "$realfile" | sed -n 's|^libhwy\.so\.\([0-9][0-9.]*\)$|\1|p'
            ;;
    esac
}

__1c_enterprise_version_ge()
{
    local ver="$1"
    local minver="$2"

    [ -n "$ver" ] || return 1
    [ -n "$minver" ] || return 1
    [ "$(printf '%s\n%s\n' "$ver" "$minver" | sort -V | tail -n1)" = "$ver" ]
}

__1c_enterprise_version_gt()
{
    local ver="$1"
    local minver="$2"

    [ -n "$ver" ] || return 1
    [ -n "$minver" ] || return 1
    [ "$ver" != "$minver" ] || return 1
    __1c_enterprise_version_ge "$ver" "$minver"
}

__1c_enterprise_assure_strings()
{
    command -v strings >/dev/null 2>&1 && return 0

    if command -v epm >/dev/null 2>&1 ; then
        epm install --skip-installed binutils || true
    fi

    command -v strings >/dev/null 2>&1 && return 0
    warning "Keeping bundled runtime libraries: strings command was not found"
    return 1
}

__1c_enterprise_best_lib_in_dir()
{
    local dir="$1"
    local libname="$2"
    local file version bestfile bestversion

    for file in "$dir/$libname" "$dir/$libname".*
    do
        [ -e "$file" ] || [ -L "$file" ] || continue
        version="$(__1c_enterprise_lib_version "$file" "$libname")"
        [ -n "$version" ] || continue
        if [ -z "$bestversion" ] || __1c_enterprise_version_ge "$version" "$bestversion" ; then
            bestfile="$file"
            bestversion="$version"
        fi
    done

    [ -n "$bestfile" ] || return 1
    echo "$bestfile"
}

__1c_enterprise_best_system_lib()
{
    local libname="$1"
    local file version bestfile bestversion

    for file in \
        /lib*/"$libname" /lib*/"$libname".* \
        /usr/lib*/"$libname" /usr/lib*/"$libname".* \
        /lib*/*/"$libname" /lib*/*/"$libname".* \
        /usr/lib*/*/"$libname" /usr/lib*/*/"$libname".*
    do
        [ -e "$file" ] || [ -L "$file" ] || continue
        version="$(__1c_enterprise_lib_version "$file" "$libname")"
        [ -n "$version" ] || continue
        if [ -z "$bestversion" ] || __1c_enterprise_version_ge "$version" "$bestversion" ; then
            bestfile="$file"
            bestversion="$version"
        fi
    done

    [ -n "$bestfile" ] || return 1
    echo "$bestfile"
}

__1c_enterprise_distro_name()
{
    if command -v distr_info >/dev/null 2>&1 ; then
        distr_info -d 2>/dev/null && return 0
    fi

    if command -v lsb_release >/dev/null 2>&1 ; then
        lsb_release -is 2>/dev/null && return 0
    fi

    sed -n 's|^ID=||p' /etc/os-release 2>/dev/null | tr -d '"' | head -n1
}

__1c_enterprise_distro_version()
{
    if command -v distr_info >/dev/null 2>&1 ; then
        distr_info -v 2>/dev/null && return 0
    fi

    if command -v lsb_release >/dev/null 2>&1 ; then
        lsb_release -r 2>/dev/null | awk '{print $NF}' && return 0
    fi

    sed -n 's|^VERSION_ID=||p' /etc/os-release 2>/dev/null | tr -d '"' | head -n1
}

__1c_enterprise_use_wk41()
{
    local distrname distrver

    distrname="$(__1c_enterprise_distro_name | tr '[:upper:]' '[:lower:]')"
    distrver="$(__1c_enterprise_distro_version | cut -d_ -f1 | cut -d. -f1)"

    case "$distrname" in
        *stra*)
            distrver="$(__1c_enterprise_distro_version | cut -d_ -f1)"
            __1c_enterprise_version_gt "$distrver" 1.7 || return 1
            ;;
        *buntu)
            __1c_enterprise_version_gt "$distrver" 23 || return 1
            ;;
        *inux*int*)
            __1c_enterprise_version_gt "$distrver" 21 || return 1
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

__1c_enterprise_remove_lib_files()
{
    local root="$1"
    local dir="$2"
    local libname="$3"
    local reldir

    reldir="${dir#$root}"

    if [ -n "$BUILDROOT" ] && [ "$root" = "$BUILDROOT" ] && command -v remove_file >/dev/null 2>&1 ; then
        remove_file "$reldir/$libname"
        remove_file "$reldir/$libname.*"
        return
    fi

    rm -fv "$dir/$libname" "$dir/$libname".*
}

__1c_enterprise_remove_bundled_runtime_libs_from_root()
{
    local root="$1"
    local dir libname bundled systemlib bundledversion systemversion

    [ -n "$root" ] || root="$BUILDROOT"
    [ -n "$root" ] || return 0
    __1c_enterprise_assure_strings || return 0

    for dir in \
        "$root"/opt/1cv8/*/* "$root"/opt/1cv8/common \
        "$root"/opt/1cv8t/*/* "$root"/opt/1cv8t/common
    do
        [ -d "$dir" ] || continue
        for libname in libstdc++.so.6 libgcc_s.so.1 libhwy.so.1 ; do
            bundled="$(__1c_enterprise_best_lib_in_dir "$dir" "$libname")" || continue
            systemlib="$(__1c_enterprise_best_system_lib "$libname")" || {
                warning "Keeping bundled $libname: system library was not found"
                continue
            }
            bundledversion="$(__1c_enterprise_lib_version "$bundled" "$libname")"
            systemversion="$(__1c_enterprise_lib_version "$systemlib" "$libname")"

            if [ -z "$bundledversion" ] || [ -z "$systemversion" ] ; then
                warning "Keeping bundled $libname: can't compare bundled and system versions"
                continue
            fi

            if __1c_enterprise_version_ge "$systemversion" "$bundledversion" ; then
                info "Removing bundled $libname $bundledversion; system $systemversion is enough"
                __1c_enterprise_remove_lib_files "$root" "$dir" "$libname"
            else
                info "Keeping bundled $libname $bundledversion; system $systemversion is older"
            fi
        done
    done
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

    subst "s|^Icon=$icon-.*|Icon=$icon|" "$BUILDROOT"/usr/share/applications/*.desktop
}

__1c_enterprise_normalize_desktop_name()
{
    local command="$1"
    local versiondir="$2"
    local desktop

    for desktop in "$BUILDROOT/usr/share/applications/$command"-*.desktop "$BUILDROOT$versiondir/$command"-*.desktop ; do
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

    __1c_enterprise_remove_bundled_runtime_libs_from_root "$BUILDROOT"
}
