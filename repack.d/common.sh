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
    elif echo "$src" | grep -q "^/" ; then
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

install_requires()
{
    [ -n "$1" ] || return
    if [ "$(epm print info -s)" = "alt" ] ; then
        epm install --skip-installed --no-remove "$@" || fatal "Can't install requires packages."
    fi
}

filter_from_requires()
{
    local i
    for i in "$@" ; do
        local ti="$(echo "$i" | sed -e 's|^/|\\\\/|' -e 's|\([^\]\)/|\1\\\\/|g')"
        subst "1i%filter_from_requires /^$ti.*/d" $SPEC
    done
}

add_findreq_skiplist()
{
    local i
    for i in "$@" ; do
        subst "1i%add_findreq_skiplist $i" $SPEC
    done
}

# ignore embedded libs
drop_embedded_reqs()
{
    filter_from_requires "libGLESv2.so()" "libEGL.so()" "libffmpeg.so()"
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
if [ -n "$PRODUCTDIR" ] && [ "$(dirname "$PRODUCTDIR" )" != "/" ] && [ "$(dirname "$(dirname "$PRODUCTDIR" )" )" != "/" ] ; then
   [ -n "$PRODUCTBASEDIR" ] || PRODUCTBASEDIR="$(dirname "$PRODUCTDIR")"
fi

[ -d "$BUILDROOT$PRODUCTBASEDIR" ] && pack_dir "$PRODUCTBASEDIR"

[ -n "$PREINSTALL_PACKAGES" ] && install_requires $PREINSTALL_PACKAGES

true
