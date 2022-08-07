#!/bin/sh

# Usage: remove_file <path_to_file>
remove_file()
{
    local file="$1"
    [ -n "$file" ] || return
    [ -e "$BUILDROOT$file" ] || [ -L "$BUILDROOT$file" ] || return

    rm -v "$BUILDROOT$file"
    subst "s|.*$file.*||" $SPEC
}

remove_dir()
{
    local file="$1"
    [ -n "$file" ] || return
    [ -d "$BUILDROOT$file" ] || return

    rm -rv "$BUILDROOT$file"
    subst "s|.*$file.*||" $SPEC
}


# Usage: pack_file <path_to_file>
pack_file()
{
    local file="$1"
    [ -n "$file" ] || return
    grep -q "^$file$" $SPEC && return
    grep -q "\"$file\"" $SPEC && return
    subst "s|%files|%files\n$file|" $SPEC
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
    echo "exec $target \"\$@\"" > $BUILDROOT/usr/bin/$name
    chmod 0755 $BUILDROOT/usr/bin/$name
    pack_file /usr/bin/$name
}

# move files to $PRODUCTDIR
move_to_opt()
{
    local from="$1"
    [ -n "$from" ] || from="/usr/share/$PRODUCT"
    mkdir -p $BUILDROOT$PRODUCTDIR/
    mv $BUILDROOT/$from/* $BUILDROOT$PRODUCTDIR/
    subst "s|$from|$PRODUCTDIR|g" $SPEC
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
