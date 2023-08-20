#!/bin/sh

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

# compatibility layer

# check if <arg> is a real command
is_command()
{
    epm tool which "$1" >/dev/null
}

# add realpath if missed
if ! is_command realpath ; then
realpath()
{
    [ -n "$*" ] || return
    readlink -f "$@"
}
fi

# add subst if missed
if ! is_command subst ; then
subst()
{
    sed -i -e "$@"
}
fi

is_abs_path()
{
    echo "$1" | grep -q "^/"
}

# Remove file from the file system and from spec
# Usage: remove_file <path_to_file>
remove_file()
{
    local file="$1"
    [ -n "$file" ] || return
    [ -e "$BUILDROOT$file" ] || [ -L "$BUILDROOT$file" ] || return

    rm -v "$BUILDROOT$file"
    subst "s|^$file$||" $SPEC
    subst "s|^\"$file\"$||" $SPEC
    subst "s|^\(%config.*\) $file$||" $SPEC
    subst "s|^\(%config.*\) \"$file\"$||" $SPEC
}

is_dir_empty()
{
    [ -z "$(ls -A "$1")" ]
}

is_url()
{
    echo "$1" | grep -q "^[filehtps]*:/"
}



# Move file to a new place
move_file()
{
    local from="$1"
    local to="$2"
    [ -e "$BUILDROOT$from" ] || return
    mkdir -p "$(dirname "$BUILDROOT$to")" || return
    cp -av "$BUILDROOT$from" "$BUILDROOT$to" || return
    remove_file "$from"
    pack_file "$to"
    # try remove dir if empty
    is_dir_empty "$(dirname "$BUILDROOT$from")" && remove_dir "$(dirname" $from")"
}

# Remove dir (recursively) from the file system and from spec
remove_dir()
{
    local file="$1"
    [ -n "$file" ] || return
    [ -d "$BUILDROOT$file/" ] || return

    # canonicalize
    file="$(echo "$file" | sed -e 's|/*$||')"

    echo "Removing $file dir ..."
    rm -r "$BUILDROOT$file/"
    # %dir "/icons/"
    subst "s|^%dir $file/*$||" $SPEC
    subst "s|^%dir \"$file/*\"$||" $SPEC
    # %dir "/icons/some..."
    subst "s|^%dir $file/.*$||" $SPEC
    subst "s|^%dir \"$file/.*\"$||" $SPEC
    # "/icons/"
    subst "s|^$file/*$||" $SPEC
    subst "s|^\"$file/*\"$||" $SPEC
    # "/icons/some..."
    subst "s|^$file/.*||" $SPEC
    subst "s|^\"$file/.*\"$||" $SPEC
    subst "s|^\(%config.*\) $file$||" $SPEC
    subst "s|^\(%config.*\) \"$file\"$||" $SPEC
    subst "s|^\(%config.*\) $file/.*||" $SPEC
    subst "s|^\(%config.*\) \"$file/.*\"$||" $SPEC
}

has_space()
{
    [ "${1/ /}" != "$1" ]
}

has_wildcard()
{
    [ "${1/\*/}" != "$1" ]
}

# Add file to spec (if missed)
# Usage: pack_file <path_to_file>
pack_file()
{
    local file="$1"
    [ -n "$file" ] || return
    grep -q "^$file$" $SPEC && return
    grep -q "\"$file\"" $SPEC && return
    has_space "$file" && file="\"$file\""
    subst "s|%files|%files\n$file|" $SPEC
}

# Add dir (only dir) to spec (if missed)
# Usage: pack_dir <path_to_dir>
pack_dir()
{
    local file="$1"
    [ -n "$file" ] || return
    grep -q "^%dir[[:space:]]$file/*$" $SPEC && return
    grep -q "^%dir[[:space:]]\"$file/*\"$" $SPEC && return
    has_space "$file" && file="\"$file\""
    subst "s|%files|%files\n%dir $file|" $SPEC
}

install_file()
{
    local src="$1"
    local dest="$2"

    mkdir -p "$BUILDROOT/$(dirname "$dest")" || return

    if is_url "$src" ; then
        epm tool eget -O "$BUILDROOT$dest" "$src" || fatal "Can't download $src to install to $dest"
    elif is_abs_path "$src" ; then
        cp "$BUILDROOT/$src" "$BUILDROOT/$dest" || return
    else
        cp "$src" "$BUILDROOT/$dest" || return
    fi

    pack_file "$dest"
}

add_bin_link_command()
{
    local name="$1"
    local target="$2"
    [ -n "$name" ] || name="$PRODUCT"
    [ -n "$target" ] || target="$PRODUCTDIR/$name"
    [ -e "$BUILDROOT/usr/bin/$name" ] && return
    [ "$name" = "$target" ] && return

    is_abs_path "$target" && chmod 0755 "$BUILDROOT$target"
    mkdir -p $BUILDROOT/usr/bin/
    ln -s "$target" "$BUILDROOT/usr/bin/$name" || return
    pack_file "/usr/bin/$name"
}


add_bin_exec_command()
{
    local name="$1"
    local target="$2"
    [ -n "$name" ] || name="$PRODUCT"
    [ -n "$target" ] || target="$PRODUCTDIR/$name"
    [ -e "$BUILDROOT/usr/bin/$name" ] && return
    [ "$name" = "$target" ] && return

    is_abs_path "$target" && chmod 0755 "$BUILDROOT$target"
    mkdir -p $BUILDROOT/usr/bin/
    cat <<EOF > "$BUILDROOT/usr/bin/$name"
#!/bin/sh
exec "$target" "\$@"
EOF
    chmod 0755 "$BUILDROOT/usr/bin/$name"
    pack_file "/usr/bin/$name"
}

add_bin_cdexec_command()
{
    local name="$1"
    local target="$2"
    [ -n "$name" ] || name="$PRODUCT"
    [ -n "$target" ] || target="$PRODUCTDIR/$name"
    [ -e "$BUILDROOT/usr/bin/$name" ] && return
    [ "$name" = "$target" ] && return

    is_abs_path "$target" && chmod 0755 "$BUILDROOT$target"
    mkdir -p $BUILDROOT/usr/bin/
    cat <<EOF > "$BUILDROOT/usr/bin/$name"
#!/bin/sh
cd "$(dirname "$target")" || exit
exec ./"$(basename "$target")" "\$@"
EOF
    chmod 0755 "$BUILDROOT/usr/bin/$name"
    pack_file "/usr/bin/$name"
}

# move files to $PRODUCTDIR
move_to_opt()
{
    local sdir rdir i

    if [ -z "$1" ] ; then
        local from
        from="/usr/share/$PRODUCTCUR"
        [ -d "$BUILDROOT$from" ] || from="/usr/share/$PRODUCT"
        [ -d "$BUILDROOT$from" ] || from="/usr/lib/$PRODUCT"
        sdir="$BUILDROOT$from"
    elif has_space "$1" ; then
        sdir="$BUILDROOT$1"
    else
        sdir=''
        for i in "$@" ; do
            # workaround for wildcards in from
            sdir="$(echo $BUILDROOT$i)"
            [ -d "$sdir" ] && break
        done
    fi

    [ -d "$sdir" ] || return 1 #fatal "Can't find any dir from $from list"

    rdir="$(echo "$sdir" | sed -e "s|^$BUILDROOT||")"
    [ -n "$rdir" ] || return 1 #fatal "Can't resolve $from in $BUILDROOT"
    [ -d "$BUILDROOT$rdir" ] || return 1 #fatal "Can't resolve $from in $BUILDROOT"

    [ -d "$BUILDROOT$PRODUCTDIR/" ] && return 1
    mkdir -p "$BUILDROOT$(dirname "$PRODUCTDIR")/"
    mv "$BUILDROOT$rdir" "$BUILDROOT$PRODUCTDIR/"
    subst "s|%dir $rdir|%dir $PRODUCTDIR|" $SPEC
    subst "s|%dir \"$rdir|%dir \"$PRODUCTDIR|" $SPEC
    subst "s|\(%config.*\) $rdir|\1 $PRODUCTDIR|" $SPEC
    subst "s|\(%config.*\) \"$rdir|\1 \"$PRODUCTDIR|" $SPEC
    subst "s|^$rdir|$PRODUCTDIR|" $SPEC
    subst "s|^\"$rdir|\"$PRODUCTDIR|" $SPEC

    pack_dir "$PRODUCTDIR"
}

# remove absolute path from desktop file
fix_desktop_file()
{
    local from="$1"
    local to="$2"
    [ -n "$from" ] || from="$PRODUCTDIR/$PRODUCT"
    [ -n "$to" ] || to="$(basename "$from")"
    subst "s|$from|$to|" $BUILDROOT/usr/share/applications/*.desktop
    chmod -v 0644 $BUILDROOT/usr/share/applications/*.desktop
}

fix_chrome_sandbox()
{
    local sandbox="$1"
    # Set SUID for chrome-sandbox if userns_clone is not supported
    # CHECKME: Also userns can be enabled via sysctl-conf-userns package install
    userns_path='/proc/sys/kernel/unprivileged_userns_clone'
    userns_val="$(cat $userns_path 2>/dev/null)"
    [ "$userns_val" = '1' ] && return
    [ -n "$sandbox" ] || sandbox="$PRODUCTDIR/chrome-sandbox"
    [ -e "$BUILDROOT$sandbox" ] || return 0
    chmod -v 4711 "$BUILDROOT$sandbox"
}

add_requires()
{
    [ -n "$1" ] || return
    [ "$(epm print info -s)" = "alt" ] || return 0
    subst "1iRequires: $*" $SPEC
}

# libstdc++.so.6 -> libstdc++.so.6()(64bit)
add_unirequires()
{
    [ -n "$1" ] || return
    if [ "$(epm print info -b)" = "64" ] ; then
        local req reqs
        reqs=''
        for req in $* ; do
            reqs="$reqs $req"
            echo "$req" | grep "^lib" | grep -q -v -F "(64bit)" && reqs="$reqs"'()(64bit)'
        done
        subst "1iRequires:$reqs" $SPEC
    else
        echo "$*" | grep -F "(64bit)" && fatal "Unsupported (64bit) on $(epm print info -a) arch."
        subst "1iRequires: $*" $SPEC
    fi
}


install_requires()
{
    [ -n "$1" ] || return
    if [ "$(epm print info -s)" = "alt" ] ; then
        epm install --skip-installed --no-remove "$@" || fatal "Can't install requires packages."
    fi
}


add_electron_deps()
{
    add_unirequires "file grep sed which xdg-utils xprop"
    add_unirequires "libpthread.so.0 libstdc++.so.6"
    add_unirequires "libX11.so.6 libXcomposite.so.1 libXdamage.so.1 libXext.so.6 libXfixes.so.3 libXrandr.so.2 libxcb.so.1 libxkbcommon.so.0"
    add_unirequires "libasound.so.2 libatk-1.0.so.0 libatk-bridge-2.0.so.0 libatspi.so.0"
    add_unirequires "libcairo.so.2 libcups.so.2 libdbus-1.so.3"
    add_unirequires "libdrm.so.2 libexpat.so.1 libfontconfig.so.1 libgbm.so.1"
    add_unirequires "libgio-2.0.so.0 libglib-2.0.so.0 libgobject-2.0.so.0 libgtk-3.so.0 libpango-1.0.so.0"
    add_unirequires "libnspr4.so libnss3.so libnssutil3.so libsmime3.so"
}

add_qt5_deps()
{
    add_unirequires "libm.so.6 libc.so.6"
    add_unirequires "libglib-2.0.so.0 libgio-2.0.so.0 libgobject-2.0.so.0 libfontconfig.so.1 libfreetype.so.6"
    add_unirequires "libEGL.so.1 libGL.so.1 libxcb.so.1 libX11.so.6 libX11-xcb.so.1 libglib-2.0.so.0"
}

add_qt6_deps()
{
    add_unirequires "libm.so.6 libc.so.6 libdl.so.2 libgcc_s.so.1 libpthread.so.0 libstdc++.so.6"
    add_unirequires "libEGL.so.1 libGL.so.1 libxcb.so.1 libX11.so.6 libX11-xcb.so.1 libglib-2.0.so.0"
    add_unirequires "libGLX.so.0 libOpenGL.so.0"
    add_unirequires "libX11-xcb.so.1 libX11.so.6 libXcomposite.so.1 libXdamage.so.1 libXext.so.6 libXfixes.so.3 libXinerama.so.1 libXrandr.so.2 libXrender.so.1 libXss.so.1 libXtst.so.6"
    add_unirequires "libasound.so.2 libdbus-1.so.3 libdrm.so.2 libexpat.so.1 libfontconfig.so.1 libfreetype.so.6 libgbm.so.1"
    add_unirequires "libglib-2.0.so.0 libgthread-2.0.so.0 libharfbuzz.so.0 libjpeg.so.8 liblcms2.so.2 libminizip.so.1"
    add_unirequires "libnspr4.so libnss3.so libnssutil3.so libopus.so.0 libpci.so.3 libplc4.so libplds4.so libpulse.so.0 libresolv.so.2 librt.so.1 libsmime3.so libsnappy.so.1"
    add_unirequires "libtiff.so.5 libudev.so.1 libva-drm.so.2 libva-x11.so.2 libva.so.2 libwayland-client.so.0 libwayland-cursor.so.0 libwayland-egl.so.1 libwayland-server.so.0"
    add_unirequires "libxcb-glx.so.0 libxcb-icccm.so.4 libxcb-image.so.0 libxcb-keysyms.so.1 libxcb-randr.so.0 libxcb-render-util.so.0 libxcb-render.so.0"
    add_unirequires "libxcb-shape.so.0 libxcb-shm.so.0 libxcb-sync.so.1 libxcb-xfixes.so.0 libxcb-xkb.so.1 libxcb.so.1"
    add_unirequires "libxkbcommon-x11.so.0 libxkbcommon.so.0 libxkbfile.so.1 libxml2.so.2 libxshmfence.so.1 libxslt.so.1 libz.so.1"
}

# fast hack to get all extra soname list
get_libs_requires()
{
    local libreqlist=$(mktemp)
    local libpreslist=$(mktemp)
    local fdir="$BUILDROOT/$1"

    find "$fdir" -type f | while read f ; do
        epm req --short $f </dev/null 2>/dev/null | sed -e 's|().*||'
    done | LANG=C sort -u >$libreqlist

    find "$fdir" -name "lib*.so*" | xargs -n1 objdump -p | grep "SONAME" | sed -e 's|.* ||' | LANG=C sort -u >$libpreslist

    LANG=C join -v2 $libpreslist $libreqlist
    rm -f $libreqlist $libpreslist
}

add_libs_requires()
{
    local ll
    echo "Scanning for required libs soname ..."
    get_libs_requires | xargs -n6 echo | while read ll ; do
        echo "Requires: $ll"
        add_unirequires "$ll" </dev/null
    done
}

# TODO: improve for other arch
is_soname_present()
{
    local libdir
    for libdir in /usr/lib/x86_64-linux-gnu /usr/lib64 /lib64 ; do
        [ -r $libdir/$1 ] && return 0
    done
    return 1
}


add_by_ldd_deps()
{
    local exe="$1"
    [ -n "$exe" ] || exe="$PRODUCTDIR/$PRODUCT"
    if is_abs_path "$exe" ; then
        exe="$BUILDROOT$exe"
    fi
    [ -x "$exe" ] || fatal "Can't get requires via ldd for non executable $1"
    add_unirequires "$(epm requires --direct "$exe")"
}

filter_from_requires()
{
    # hack for uncompatible rpm-build
    [ -n "$EPM_RPMBUILD" ] && return
    local i
    for i in "$@" ; do
        local ti="$(echo "$i" | sed -e 's|^/|\\\\/|' -e 's|\([^\]\)/|\1\\\\/|g')"
        subst "1i%filter_from_requires /^$ti.*/d" $SPEC
    done
}

add_findreq_skiplist()
{
    # hack for uncompatible rpm-build
    [ -n "$EPM_RPMBUILD" ] && return
    local i
    for i in "$@" ; do
        subst "1i%add_findreq_skiplist $i" $SPEC
    done
}

set_autoreq()
{
    if cat $SPEC | grep -q "^AutoReq:" ; then
        subst "s|^AutoReq:.*|AutoReq: $*|" $SPEC
    else
        subst "1iAutoReq: $*" $SPEC
    fi
}

set_autoprov()
{
    if cat $SPEC | grep -q "^AutoProv:" ; then
        subst "s|^AutoProv:.*|AutoProv: $*|" $SPEC
    else
        subst "1iAutoProv: $*" $SPEC
    fi
}

# https://bugzilla.altlinux.org/42189
fix_cpio_bug_links()
{
    local rlink
    find -type l | while read link ; do
        rlink="$(readlink "$link")"
        echo "$rlink" | grep -E "^(etc|var|opt|usr)/" || continue
        echo "Fixing cpio ALT bug 42189 in $link <- $rlink" >&2
        rm -v $link
        ln -sv /$rlink $link
    done
}

# by default check in $PRODUCTDIR
use_system_xdg()
{
    local prod="$1"
    [ -n "$prod" ] || prod="$PRODUCTDIR"
    # replace embedded xdg tools
    for i in $prod/{xdg-mime,xdg-settings} ; do
        [ -s $BUILDROOT$i ] || continue
        rm -v $BUILDROOT$i
        ln -s /usr/bin/$(basename $i) $BUILDROOT$i
    done
}


#[ -d "$BUILDROOT" ] || fatal "Run me only via epm repack <package>"

[ -n "$PRODUCT" ] || PRODUCT="$(basename $0 .sh)"

[ -n "$PRODUCTCUR" ] || PRODUCTCUR="$PRODUCT"
[ -n "$PRODUCTDIR" ] || PRODUCTDIR="/opt/$PRODUCTCUR"

[ -d "$BUILDROOT$PRODUCTDIR" ] && pack_dir "$PRODUCTDIR"


# like /opt/yandex/browser
if [ -n "$PRODUCTDIR" ] && [ "$(dirname "$PRODUCTDIR" )" != "/" ] && [ "$(dirname "$(dirname "$PRODUCTDIR" )" )" != "/" ] ; then #"
   [ -n "$PRODUCTBASEDIR" ] || PRODUCTBASEDIR="$(dirname "$PRODUCTDIR")"
fi

[ -d "$BUILDROOT$PRODUCTBASEDIR" ] && [ "$PRODUCTBASEDIR" != "/usr/lib" ] && pack_dir "$PRODUCTBASEDIR"

[ -n "$PREINSTALL_PACKAGES" ] && install_requires $PREINSTALL_PACKAGES

[ -n "$UNIREQUIRES" ] && add_unirequires $UNIREQUIRES

true
