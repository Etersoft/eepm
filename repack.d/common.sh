#!/bin/sh

# kind of hack: inheritance --force from main epm
echo "$EPM_OPTIONS" | grep -q -- "--nodeps" && nodeps="--nodeps"
echo "$EPM_OPTIONS" | grep -q -- "--verbose" && verbose="--verbose"

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    echo "$*" >&2
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

estrlist()
{
    epm tool estrlist "$@"
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

# Usage: <local file> </abs/path/to/file>
install_file()
{
    local src="$1"
    local dest="$2"

    mkdir -p "$BUILDROOT/$(dirname "$dest")" || return

    if is_url "$src" ; then
        epm tool eget -O "$BUILDROOT$dest" "$src" || fatal "Can't download $src to install to $dest"
    elif [ "$src" = "/dev/stdin" ] ; then
        cp "$src" "$BUILDROOT/$dest" || return
    elif is_abs_path "$src" ; then
        cp "$BUILDROOT/$src" "$BUILDROOT/$dest" || return
    else
        cp "$src" "$BUILDROOT/$dest" || return
    fi

    chmod 0644 "$BUILDROOT/$dest"
    pack_file "$dest"
}

# Create target file from file
# Usage: echo "text" | create_file /abs/path/to/file
create_file()
{
    local t="$1"
    install_file /dev/stdin $t
}

__check_target_bin()
{
    local target="$1"
    if is_abs_path "$target" ; then
        # if target does not exist
        [ -e "$BUILDROOT$target" ] || fatal "fatal on broken link creating (missed target $target for add_bin_*_command)"
        chmod 0755 "$BUILDROOT$target" || fatal
    else
        # if target is a relative, skiping when /usr/bin/$name exists
        [ -e "$BUILDROOT/usr/bin/$name" ] && return
    fi

}

add_bin_link_command()
{
    local name="$1"
    local target="$2"
    [ -n "$name" ] || name="$PRODUCT"
    [ -n "$target" ] || target="$PRODUCTDIR/$name"
    [ "$name" = "$target" ] && return

    __check_target_bin "$target"
    mkdir -p $BUILDROOT/usr/bin/
    ln -sf "$target" "$BUILDROOT/usr/bin/$name" || return
    pack_file "/usr/bin/$name"
}


add_bin_exec_command()
{
    local name="$1"
    local target="$2"
    [ -n "$name" ] || name="$PRODUCT"
    [ -n "$target" ] || target="$PRODUCTDIR/$name"
    [ "$name" = "$target" ] && return

    __check_target_bin "$target"
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
    [ "$name" = "$target" ] && return

    __check_target_bin "$target"
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
        [ -d "$BUILDROOT$from" ] || from="/$(echo opt/*)"
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

    # already there
    [ "$rdir" = "$PRODUCTDIR" ] && return

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
    #[ "$userns_val" = '1' ] && return
    [ -n "$sandbox" ] || sandbox="$PRODUCTDIR/chrome-sandbox"
    [ -e "$BUILDROOT$sandbox" ] || return 0
    chmod -v 4711 "$BUILDROOT$sandbox"
}

__add_tag_after_d()
{
    subst "s|^\(Distribution:.*\)|\1\n$*|" $SPEC
}

add_requires()
{
    [ -n "$1" ] || return
    [ "$(epm print info -s)" = "alt" ] || return 0
    __add_tag_after_d "Requires: $*"
}

add_conflicts()
{
    [ -n "$1" ] || return
    __add_tag_after_d "Conflicts: $*"
}

add_provides()
{
    [ -n "$1" ] || return
    __add_tag_after_d "Provides: $*"
}


# libstdc++.so.6 -> libstdc++.so.6()(64bit)
add_unirequires()
{
    [ -n "$1" ] || return

    # cache arch
    [ -z "$EPMARCH" ] && EPMARCH="$(epm print info -b)"

    # FIXME: use package arch, not system arch
    if [ "$EPMARCH" = "64" ] ; then
        local req reqs
        reqs=''
        while IFS= read -r file ; do
            if file "$file" | grep -q "ELF 32-bit" ; then
                X32_ARCH="true"
                break
            fi
        done < <(find "$BUILDROOT" -type f -executable)
        for req in $* ; do
            reqs="$reqs $req"
            if [ "$X32_ARCH" != "true" ] ; then
                echo "$req" | grep "^lib.*\.so" | grep -q -v -F "(64bit)" && reqs="$reqs"'()(64bit)'
            fi
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

__get_binary_requires()
{
    local fdir="$1"

    info "  Getting executable requires ..."
    epm req --short $(find "$fdir" -type f -executable) </dev/null 2>/dev/null | sed -e 's|().*||'

    info "  Getting libs requires ..."
    epm req --short $(find "$fdir" -type f -name "lib*.so*") </dev/null 2>/dev/null | sed -e 's|().*||'
}

__get_library_provides()
{
    local fdir="$1"

    info "  Getting internal provides ..."
    for libso in $(find "$fdir" -name "lib*.so*") ; do
        objdump -p "$libso" | grep "SONAME" | sed -e 's|.* ||'
        basename "$libso"
    done

    echo "$EEPM_IGNORE_LIB_REQUIRES" | xargs -n1 echo
}

# fast hack to get all extra soname list
get_libs_requires()
{
    local libreqlist=$(mktemp)
    local libpreslist=$(mktemp)
    local fdir="$BUILDROOT/$1"

    __get_binary_requires "$fdir" | LANG=C sort -u >$libreqlist
    estrlist reg_exclude "$EEPM_IGNORE_LIB_REQUIRES" "$(cat $libreqlist)" >$libreqlist
    if [ -n "$verbose" ] ; then
        info "  List of binary and libs requires:"
        info "$(cat $libreqlist | xargs -n1000)"
        info "  End of the list binary and libs requires."
    fi

    __get_library_provides "$fdir" | LANG=C sort -u >$libpreslist
    if [ -n "$verbose" ] ; then
        info "  List of libraries provided:"
        info "$(cat $libpreslist | xargs -n1000)"
        info "  End of the provided libraries list."

        info "  List of ignored libraries:"
        info "$EEPM_IGNORE_LIB_REQUIRES"
        info "  End of the ignored libraries."
    fi

    # print out result
    LANG=C join -v2 $libpreslist $libreqlist
    rm -f $libreqlist $libpreslist
}

add_libs_requires()
{
    local ll
    [ -n "$nodeps" ] && info "Skipping any requires detection ..." && return
    info "Scanning for required libs soname ..."
    get_libs_requires | xargs -n6 echo | grep -ve '^$' | while read ll ; do
        info "Requires: $ll"
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

# TODO: remove
filter_from_requires()
{
    # ALT specific only
    [ "$(epm print info -s)" = "alt" ] || return 0
    # hack for uncompatible rpm-build
    [ -n "$EPM_RPMBUILD" ] && return
    local i
    for i in "$@" ; do
        local ti="$(echo "$i" | sed -e 's|^/|\\\\/|' -e 's|\([^\]\)/|\1\\\\/|g')"
        subst "1i%filter_from_requires /^$ti.*/d" $SPEC
    done
}

ignore_lib_requires()
{
   #if [ -z "$EPM_RPMBUILD" ] ; then
   #    filter_from_requires "$@"
   #    return
   #fi

   EEPM_IGNORE_LIB_REQUIRES="$EEPM_IGNORE_LIB_REQUIRES $@"
}


add_findreq_skiplist()
{
    # ALT specific only
    [ "$(epm print info -s)" = "alt" ] || return 0
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
    # ALT specific only
    [ "$(epm print info -s)" = "alt" ] || return 0

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


[ -d "$BUILDROOT" ] || fatal "Run me only via epm repack <package>"

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
