#!/bin/sh

# compatibility layer
# add realpath if missed
if ! which realpath 2>/dev/null >/dev/null ; then
realpath()
{
    [ -n "$*" ] || return
    readlink -f "$@"
}
fi

# add subst if missed
if ! which subst 2>/dev/null >/dev/null ; then
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
    subst "s|.*$file.*||" $SPEC
}

is_dir_empty()
{
    [ -z "$(ls -A "$1")" ]
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
    subst "s|.*$file/.*||" $SPEC
    subst "s|.*$file\"$||" $SPEC
    subst "s|.*$file$||" $SPEC
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

# move files to $PRODUCTDIR
move_to_opt()
{
    local sdir rdir i
    mkdir -p "$BUILDROOT$PRODUCTDIR/"

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
        for i in $* ; do
            # workaround for wildcards in from
            sdir="$(echo $BUILDROOT$i)"
            [ -d "$sdir" ] && break
        done
    fi

    [ -d "$sdir" ] || return 1 #fatal "Can't find any dir from $from list"

    rdir="$(echo "$sdir" | sed -e "s|^$BUILDROOT||")"
    [ -n "$rdir" ] || return 1 #fatal "Can't resolve $from in $BUILDROOT"
    [ -d "$BUILDROOT$rdir" ] || return 1 #fatal "Can't resolve $from in $BUILDROOT"

    mv "$BUILDROOT$rdir"/* "$BUILDROOT$PRODUCTDIR/"
    subst "s|$rdir|$PRODUCTDIR|g" $SPEC
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

filter_from_requires()
{
    local i
    for i in "$@" ; do
        subst "1i%filter_from_requires /^$i.*/d" $SPEC
    done
}

# ignore embedded libs
drop_embedded_reqs()
{
    filter_from_requires "libGLESv2.so()" "libEGL.so()" "libffmpeg.so()"
}

if [ -n "$PRODUCT" ] ; then
    [ -n "$PRODUCTCUR" ] || PRODUCTCUR="$PRODUCT"
    [ -n "$PRODUCTDIR" ] || PRODUCTDIR="/opt/$PRODUCTCUR"

    [ -d "$BUILDROOT$PRODUCTDIR" ] && pack_dir "$PRODUCTDIR"
fi
