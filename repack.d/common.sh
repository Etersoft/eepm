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


# Add file to spec (if missed)
# Usage: pack_file <path_to_file>
pack_file()
{
    local file="$1"
    [ -n "$file" ] || return
    grep -q "^$file$" $SPEC && return
    grep -q "\"$file\"" $SPEC && return
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
    subst "s|%files|%files\n%dir $file|" $SPEC
}


add_bin_link_command()
{
    local name="$1"
    local target="$2"
    [ -n "$name" ] || name="$PRODUCT"
    [ -n "$target" ] || target="$PRODUCTDIR/$name"
    [ -e $BUILDROOT/usr/bin/$name ] && return

    mkdir -p $BUILDROOT/usr/bin/
    ln -s $target $BUILDROOT/usr/bin/$name
    pack_file /usr/bin/$name
}


add_bin_exec_command()
{
    local name="$1"
    local target="$2"
    [ -n "$name" ] || name="$PRODUCT"
    [ -n "$target" ] || target="$PRODUCTDIR/$name"
    [ -e $BUILDROOT/usr/bin/$name ] && return

    mkdir -p $BUILDROOT/usr/bin/
    cat <<EOF > $BUILDROOT/usr/bin/$name
#!/bin/sh
exec $target "\$@"
EOF
    chmod 0755 $BUILDROOT/usr/bin/$name
    pack_file /usr/bin/$name
}

# move files to $PRODUCTDIR
move_to_opt()
{
    local from="$*"
    if [ -z "$from" ] ; then
        from="/usr/share/$PRODUCTCUR"
        [ -d "$BUILDROOT$from" ] || from="/usr/share/$PRODUCT"
        [ -d "$BUILDROOT$from" ] || from="/usr/lib/$PRODUCT"
    fi
    mkdir -p $BUILDROOT$PRODUCTDIR/

    local sdir rdir i
    for i in $from ; do
        # workaround for wildcards in from
        sdir="$(echo $BUILDROOT$i)"
        [ -d "$sdir" ] || continue
        rdir="$(echo $sdir | sed -e "s|^$BUILDROOT||")"
        [ -n "$rdir" ] || return 1 #fatal "Can't resolve $from in $BUILDROOT"
        [ -d "$BUILDROOT$rdir" ] || return 1 #fatal "Can't resolve $from in $BUILDROOT"
        break
    done
    [ -d "$sdir" ] || return 1 #fatal "Can't find any dir from $from list"

    mv $BUILDROOT$rdir/* $BUILDROOT$PRODUCTDIR/
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
    [ -n "$sandbox" ] || sandbox=$PRODUCTDIR/chrome-sandbox
    [ -e "$BUILDROOT$sandbox" ] || return 0
    chmod -v 4711 $BUILDROOT$sandbox
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

    [ -d "$BUILDROOT$PRODUCTDIR" ] && pack_dir $PRODUCTDIR
fi
